#include "ipc.hpp"

#include <QChar>
#include <QLocalSocket>
#include <QObject>
#include <QString>
#include <QtGlobal>
#include <qlogging.h>
#include <qloggingcategory.h>

Q_LOGGING_CATEGORY(logNullspaceIpc, "topbar.nullspace.ipc", QtInfoMsg)

namespace topbar::nullspace {

namespace {

constexpr int RECONNECT_INTERVAL_MS = 3000;
// NOLINTBEGIN(misc-include-cleaner)
QString socketPath() {
    const auto runtime = qEnvironmentVariable("XDG_RUNTIME_DIR");
    if (runtime.isEmpty()) return {};

    const auto display = qEnvironmentVariable("WAYLAND_DISPLAY");
    if (display.isEmpty()) return runtime + QStringLiteral("/nullspace.sock");

    return runtime + QStringLiteral("/nullspace-") + display
         + QStringLiteral(".sock");
}

QString unquote(const QString &s) {
    if (s.size() < 2 || !s.startsWith(QLatin1Char('"'))
        || !s.endsWith(QLatin1Char('"'))) {
        return s;
    }

    QString out;
    out.reserve(s.size() - 2);

    for (qsizetype i = 1; i < s.size() - 1; ++i) {
        const QChar ch = s.at(i);
        if (ch == QLatin1Char('\\') && i + 1 < s.size() - 1) {
            const QChar next = s.at(++i);
            switch (next.unicode()) {
                case 'n': out.append(QLatin1Char('\n')); break;
                case 'r': out.append(QLatin1Char('\r')); break;
                case 't': out.append(QLatin1Char('\t')); break;
                case '"': out.append(QLatin1Char('"')); break;
                case '\\': out.append(QLatin1Char('\\')); break;
                default: out.append(next); break;
            }
        } else {
            out.append(ch);
        }
    }

    return out;
}

} // namespace

IpcClient::IpcClient(QObject *parent) : QObject(parent) {
    this->mReconnectTimer.setSingleShot(true);

    QObject::connect(
        &this->mReconnectTimer, &QTimer::timeout, this, &IpcClient::tryReconnect
    );

    QObject::connect(
        &this->mSocket, &QLocalSocket::connected, this, &IpcClient::onConnected
    );

    QObject::connect(
        &this->mSocket, &QLocalSocket::disconnected, this,
        &IpcClient::onDisconnected
    );

    QObject::connect(
        &this->mSocket, &QLocalSocket::errorOccurred, this,
        &IpcClient::onErrorOccurred
    );

    QObject::connect(
        &this->mSocket, &QLocalSocket::readyRead, this, &IpcClient::onReadyRead
    );

    this->connectSocket();
}

void IpcClient::connectSocket() {
    if (this->mSocket.state() != QLocalSocket::UnconnectedState) return;

    const auto path = socketPath();
    if (path.isEmpty()) {
        qCWarning(logNullspaceIpc) << "XDG_RUNTIME_DIR is not set";
        this->mReconnectTimer.start(RECONNECT_INTERVAL_MS);
        return;
    }

    this->mSocket.connectToServer(path);
}

void IpcClient::tryReconnect() { this->connectSocket(); }

void IpcClient::onConnected() {
    qCInfo(logNullspaceIpc) << "Socket connected";

    this->mConnected = true;
    this->mReadBuffer.clear();
    this->mSocket.write("SUBSCRIBE\n");
    this->mSocket.flush();

    emit this->connectedChanged();
}

void IpcClient::onDisconnected() {
    qCInfo(logNullspaceIpc) << "Socket disconnected";

    const bool wasConnected = this->mConnected;
    this->mConnected = false;

    if (wasConnected) emit this->connectedChanged();

    this->mReconnectTimer.start(RECONNECT_INTERVAL_MS);
}

void IpcClient::onErrorOccurred() {
    if (this->mSocket.error() == QLocalSocket::PeerClosedError) return;

    qCWarning(logNullspaceIpc)
        << "Socket error:" << this->mSocket.errorString();

    const bool wasConnected = this->mConnected;
    this->mConnected = false;

    if (wasConnected) emit this->connectedChanged();
    this->mReconnectTimer.start(RECONNECT_INTERVAL_MS);
}

void IpcClient::onReadyRead() {
    this->mReadBuffer.append(this->mSocket.readAll());

    qsizetype newlineIndex = -1;
    while ((newlineIndex = this->mReadBuffer.indexOf('\n')) != -1) {
        const QByteArray line = this->mReadBuffer.left(newlineIndex);
        this->mReadBuffer.remove(0, newlineIndex + 1);
        this->processLine(line);
    }
}

void IpcClient::send(const QString &line) {
    if (!this->mConnected) {
        qCWarning(logNullspaceIpc) << "Cannot send while disconnected:" << line;
        return;
    }

    this->mSocket.write(line.toUtf8());
    this->mSocket.write("\n");
    this->mSocket.flush();
}

void IpcClient::processLine(const QByteArray &line) {
    const auto trimmed = line.trimmed();
    if (trimmed.isEmpty()) return;
    if (trimmed.startsWith("OK")) return;
    if (trimmed.startsWith("ERR")) {
        qCWarning(logNullspaceIpc) << "IPC error:" << trimmed;
        return;
    }

    if (!trimmed.startsWith("EVT ")) return;

    const auto payload = trimmed.mid(4);

    const qsizetype spaceIdx = payload.indexOf(' ');
    if (spaceIdx < 0) return;

    const auto key = QString::fromUtf8(payload.left(spaceIdx));
    const auto rawValue = QString::fromUtf8(payload.mid(spaceIdx + 1));
    emit this->eventReceived(key, unquote(rawValue));
}
// NOLINTEND(misc-include-cleaner)
} // namespace topbar::nullspace
