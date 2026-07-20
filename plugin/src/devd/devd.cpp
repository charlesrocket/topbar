#include "devd.hpp"

#include <QQmlEngine>
#include <cerrno>
#include <cstddef>
#include <cstring>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

namespace topbar::devd {

Q_LOGGING_CATEGORY(logDevd, "topbar.devd")

Devd *Devd::dInstance = nullptr;

Devd::Devd(QObject *parent) : QObject(parent) {
    dInstance = this;
    connectToDevd();
}

Devd::~Devd() {
    this->cleanup();
    dInstance = nullptr;
}

Devd *Devd::instance() {
    if (!dInstance) { dInstance = new Devd(); }
    return dInstance;
}

bool Devd::isConnected() const { return this->mConnected; }

void Devd::connectToDevd() {
    if (this->mConnected) {
        qCDebug(logDevd) << "Already connected" << this;
        return;
    }

    auto fd = socket(AF_UNIX, SOCK_SEQPACKET | SOCK_NONBLOCK, 0);
    if (fd < 0) {
        qCWarning(logDevd) << "Failed to create socket:"
                           << qt_error_string(errno);

        return;
    }

    struct sockaddr_un addr = {};
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, devdPipe, sizeof(addr.sun_path) - 1);

    if (::connect(
            fd, reinterpret_cast<struct sockaddr *>(&addr),
            static_cast<socklen_t>(SUN_LEN(&addr))
        )
        != 0) {
        qCWarning(logDevd) << "Failed to connect to" << devdPipe
                           << qt_error_string(errno);

        close(fd);
        return;
    }

    this->mFd = fd;
    this->mNotifier = new QSocketNotifier(fd, QSocketNotifier::Read, this);

    connect(
        this->mNotifier, &QSocketNotifier::activated, this,
        &Devd::onSocketActivated
    );

    this->mConnected = true;

    emit this->connectedChanged();
    qCInfo(logDevd) << "Connected to" << devdPipe;
}

void Devd::onSocketActivated() {
    this->mNotifier->setEnabled(false);

    QByteArray buf(devdMaxBuf, Qt::Uninitialized);
    const ssize_t n =
        ::recv(this->mFd, buf.data(), static_cast<size_t>(buf.size()), 0);

    if (n > 0) {
        buf.truncate(static_cast<qsizetype>(n));
        const auto line = buf.trimmed();
        if (!line.isEmpty()) {
            qCDebug(logDevd) << "Event" << line;
            emit this->eventReceived(QString::fromUtf8(line));
        }
    } else if (n == 0) {
        qCWarning(logDevd) << "Socket closed";
        this->onDisconnected();
    } else {
        const int savedErrno = errno;
        if (savedErrno != EAGAIN && savedErrno != EWOULDBLOCK) {
            qCWarning(logDevd) << "Read error:" << qt_error_string(savedErrno);
            this->onDisconnected();
        }
    }

    if (this->mNotifier) { this->mNotifier->setEnabled(true); }
}

void Devd::attemptReconnect() {
    qCInfo(logDevd) << "Attempting to reconnect";
    this->connectToDevd();
    if (this->mConnected) { this->mReconnectTimer->stop(); }
}

void Devd::scheduleReconnect() {
    if (!this->mReconnectTimer) {
        this->mReconnectTimer = new QTimer(this);
        this->mReconnectTimer->setSingleShot(false);

        connect(
            this->mReconnectTimer, &QTimer::timeout, this,
            &Devd::attemptReconnect
        );
    }

    if (!this->mReconnectTimer->isActive()) {
        this->mReconnectTimer->start(reconnectIntervalMs);
    }
}

void Devd::onDisconnected() {
    qCWarning(logDevd) << "Disconnected";

    this->cleanup();
    this->scheduleReconnect();
}

void Devd::cleanup() {
    if (this->mNotifier) {
        this->mNotifier->setEnabled(false);
        delete this->mNotifier;
        this->mNotifier = nullptr;
    }

    if (this->mFd >= 0) {
        ::close(this->mFd);
        this->mFd = -1;
    }

    if (this->mConnected) {
        this->mConnected = false;
        emit this->connectedChanged();
    }

    if (this->mReconnectTimer) { this->mReconnectTimer->stop(); }
}

} // namespace topbar::devd
