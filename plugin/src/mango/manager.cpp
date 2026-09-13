#include "manager.hpp"

#include "output.hpp"

#include <QProcessEnvironment>
#include <QtGlobal>
#include <qapplication.h>
#include <qbytearray.h>
#include <qguiapplication.h>
#include <qjsonarray.h>
#include <qjsondocument.h>
#include <qjsonobject.h>
#include <qjsonvalue.h>
#include <qlist.h>
#include <qlocalsocket.h>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qscreen.h>
#include <qstring.h>
#include <qstringlist.h>
#include <qtimer.h>

namespace topbar::mango {

Q_LOGGING_CATEGORY(logMangoIpc, "topbar.mango.ipc")

namespace {

constexpr const char *INSTANCE_SIGNATURE_ENV = "MANGO_INSTANCE_SIGNATURE";

constexpr int RECONNECT_INTERVAL_MS = 2000;

} // namespace

MangoIpcManager::MangoIpcManager() : QObject(nullptr) {
    this->mReconnectTimer.setSingleShot(true);
    QObject::connect(
        &this->mReconnectTimer, &QTimer::timeout, this,
        &MangoIpcManager::reconnect
    );

    QObject::connect(
        &this->mSocket, &QLocalSocket::connected, this,
        &MangoIpcManager::onSocketConnected
    );

    QObject::connect(
        &this->mSocket, &QLocalSocket::disconnected, this,
        &MangoIpcManager::onSocketDisconnected
    );

    QObject::connect(
        &this->mSocket, &QLocalSocket::errorOccurred, this,
        &MangoIpcManager::onSocketErrorOccurred
    );

    QObject::connect(
        &this->mSocket, &QLocalSocket::readyRead, this,
        &MangoIpcManager::onSocketReadyRead
    );

    const auto screens = QGuiApplication::screens();
    for (QScreen *screen : screens) this->onScreenAdded(screen);

    QObject::connect(
        qApp, &QGuiApplication::screenAdded, this,
        &MangoIpcManager::onScreenAdded
    );

    QObject::connect(
        qApp, &QGuiApplication::screenRemoved, this,
        &MangoIpcManager::onScreenRemoved
    );

    this->connectSocket();
}

void MangoIpcManager::onScreenAdded(QScreen *screen) {
    this->outputForName(screen->name(), true);
}

// NOLINTBEGIN(misc-include-cleaner)

void MangoIpcManager::onScreenRemoved(QScreen *screen) {
    auto *output = this->mOutputMap.take(screen->name());
    if (!output) return;

    this->mOutputs.removeOne(output);
    emit this->outputRemoved(output);
    output->deleteLater();
}

MangoIpcManager *MangoIpcManager::instance() {
    static auto *instance = new MangoIpcManager();
    return instance;
}

quint32 MangoIpcManager::tagCount() const { return this->mTagCount; }
QStringList MangoIpcManager::layouts() const { return this->mLayouts; }
QList<MangoIpcOutput *> MangoIpcManager::outputs() const {
    return this->mOutputs;
}

bool MangoIpcManager::isActive() const { return this->mConnected; }

void MangoIpcManager::connectSocket() {
    const auto env = qEnvironmentVariable(INSTANCE_SIGNATURE_ENV);
    if (env.isEmpty()) {
        qCWarning(logMangoIpc) << "MANGO_INSTANCE_SIGNATURE is missing!";
        this->mReconnectTimer.start(RECONNECT_INTERVAL_MS);
        return;
    }

    if (this->mSocket.state() != QLocalSocket::UnconnectedState) return;

    this->mSocket.connectToServer(env);
}

void MangoIpcManager::reconnect() { this->connectSocket(); }

void MangoIpcManager::onSocketConnected() {
    qCInfo(logMangoIpc) << "connected to socket";
    this->mConnected = true;
    this->mReadBuffer.clear();
    this->mSocket.write("watch all-monitors\n");

    this->requestLayouts();

    emit this->activeChanged();
}

void MangoIpcManager::onSocketDisconnected() {
    qCWarning(logMangoIpc) << "disconnected from socket";
    const bool wasConnected = this->mConnected;
    this->mConnected = false;
    if (wasConnected) emit this->activeChanged();
    this->mReconnectTimer.start(RECONNECT_INTERVAL_MS);
}

void MangoIpcManager::onSocketErrorOccurred() {
    if (this->mSocket.error() == QLocalSocket::PeerClosedError) return;

    qCWarning(logMangoIpc) << "IPC socket error:"
                           << this->mSocket.errorString();

    const bool wasConnected = this->mConnected;
    this->mConnected = false;
    if (wasConnected) emit this->activeChanged();
    this->mReconnectTimer.start(RECONNECT_INTERVAL_MS);
}

void MangoIpcManager::onSocketReadyRead() {
    this->mReadBuffer.append(this->mSocket.readAll());

    qsizetype newlineIndex = -1;
    while ((newlineIndex = this->mReadBuffer.indexOf('\n')) != -1) {
        const QByteArray line = this->mReadBuffer.left(newlineIndex);
        this->mReadBuffer.remove(0, newlineIndex + 1);
        this->processLine(line);
    }
}

// NOLINTEND(misc-include-cleaner)

void MangoIpcManager::processLine(const QByteArray &line) {
    if (line.trimmed().isEmpty()) return;

    QJsonParseError parseError{};
    const auto doc = QJsonDocument::fromJson(line, &parseError);
    if (parseError.error != QJsonParseError::NoError || !doc.isObject()) {
        qCWarning(logMangoIpc)
            << "failed to parse mango IPC message:" << parseError.errorString();
        return;
    }

    this->handleTopLevelMessage(doc.object());
}

void MangoIpcManager::handleTopLevelMessage(const QJsonObject &root) {
    if (const auto monitors = root.value("monitors"); monitors.isArray()) {
        for (const auto &entry : monitors.toArray())
            if (entry.isObject()) this->handleMonitorObject(entry.toObject());
    } else if (root.contains("name")) {
        this->handleMonitorObject(root);
    }

    if (const auto layouts = root.value("layouts"); layouts.isArray()) {
        QStringList names;
        for (const auto &entry : layouts.toArray()) {
            if (entry.isString()) {
                names.append(entry.toString());
            } else if (entry.isObject()) {
                const auto obj = entry.toObject();
                const auto name = obj.contains("name") ? obj.value("name")
                                                       : obj.value("symbol");

                if (name.isString()) names.append(name.toString());
            }
        }

        if (!names.isEmpty()) this->setLayouts(names);
    }

    if (const auto kbLayout = root.value("keyboardlayout");
        kbLayout.isString()) {
        QJsonObject partial;
        partial.insert("kb_layout", kbLayout);
        for (MangoIpcOutput *output : this->mOutputs)
            output->applyJson(partial);
    }
}

MangoIpcOutput *
MangoIpcManager::outputForName(const QString &name, bool createIfMissing) {
    if (name.isEmpty()) return nullptr;

    if (auto *existing = this->mOutputMap.value(name, nullptr)) return existing;
    if (!createIfMissing) return nullptr;

    auto *output = new MangoIpcOutput(name, this, this);
    output->initTags(this->mTagCount > 0 ? this->mTagCount : 9);
    this->mOutputs.append(output);
    this->mOutputMap.insert(name, output);
    emit this->outputAdded(output);

    return output;
}

void MangoIpcManager::handleMonitorObject(const QJsonObject &monitor) {
    const auto nameValue = monitor.value("name");
    if (!nameValue.isString()) return;

    auto *output = this->outputForName(nameValue.toString(), false);
    if (!output) return;

    if (const auto tagNum = monitor.value("tag_num"); tagNum.isDouble()) {
        const auto n = static_cast<quint32>(tagNum.toInt());
        if (n >= 1 && n != this->mTagCount) {
            this->mTagCount = n;
            for (MangoIpcOutput *o : this->mOutputs) o->initTags(n);
            emit this->tagCountChanged();
        }
    }

    output->applyJson(monitor);
}

void MangoIpcManager::setLayouts(const QStringList &layouts) {
    if (layouts == this->mLayouts) return;
    this->mLayouts = layouts;
    emit this->layoutsChanged();
}

quint32 MangoIpcManager::indexForLayoutSymbol(const QString &symbol) {
    if (symbol.isEmpty()) return 0;

    const auto existing = this->mLayouts.indexOf(symbol);
    if (existing >= 0) return static_cast<quint32>(existing);

    this->mLayouts.append(symbol);
    emit this->layoutsChanged();
    return static_cast<quint32>(this->mLayouts.size() - 1);
}

void MangoIpcManager::requestLayouts() const {
    this->sendCommand("get layouts");
}

void MangoIpcManager::sendCommand(const QString &line) const {
    if (!this->mConnected) {
        qCWarning(logMangoIpc)
            << "cannot send command while disconnected" << line;
        return;
    }

    auto *cmdSocket = new QLocalSocket();
    QObject::connect(
        cmdSocket, &QLocalSocket::connected, cmdSocket,
        [cmdSocket, line]() {
            cmdSocket->write((line + "\n").toUtf8());
            cmdSocket->flush();
            cmdSocket->disconnectFromServer();
        }
    );

    auto cleanup = [cmdSocket]() { cmdSocket->deleteLater(); };
    QObject::connect(
        cmdSocket, &QLocalSocket::disconnected, cmdSocket, cleanup
    );

    QObject::connect(
        cmdSocket, &QLocalSocket::errorOccurred, cmdSocket, cleanup
    );

    cmdSocket->connectToServer(qEnvironmentVariable(INSTANCE_SIGNATURE_ENV));
}

} // namespace topbar::mango
