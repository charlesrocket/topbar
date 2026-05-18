#include "devd.hpp"

#include <array>
#include <cerrno>
#include <cstring>
#include <fcntl.h>
#include <qfile.h>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/un.h>
#include <unistd.h>

namespace topbar::devd {

Q_LOGGING_CATEGORY(logDevd, "topbar.devd")

Devd::Devd(QObject *parent) : QObject(parent) { this->connectToDevd(); }
Devd::~Devd() { this->cleanup(); }
bool Devd::isConnected() const { return this->mConnected; }

void Devd::connectToDevd() {
    const auto *path = "/var/run/devd.seqpacket.pipe";

    if (!QFile::exists(path)) {
        qCWarning(logDevd) << "Socket does not exist:" << path
                           << "— event monitoring is disabled";
        return;
    }

    int fd = ::socket(AF_UNIX, SOCK_SEQPACKET, 0);
    if (fd < 0) {
        qCWarning(logDevd) << "Failed to create socket:"
                           << qt_error_string(errno);

        return;
    }

    struct sockaddr_un addr = {};
    addr.sun_family = AF_UNIX;
    ::strncpy(addr.sun_path, path, sizeof(addr.sun_path) - 1);

    if (::connect(
            fd, reinterpret_cast<struct sockaddr *>(&addr),
            static_cast<socklen_t>(SUN_LEN(&addr))
        )
        != 0) {
        qCWarning(logDevd) << "Failed to connect to" << path << ":"
                           << qt_error_string(errno);

        ::close(fd);
        return;
    }

    const int flags = ::fcntl(fd, F_GETFL, 0);
    if (flags < 0) {
        qCWarning(logDevd) << "fcntl F_GETFL failed:" << qt_error_string(errno);
        ::close(fd);
        return;
    }

    if (::fcntl(fd, F_SETFL, flags | O_NONBLOCK) < 0) {
        qCWarning(logDevd) << "fcntl F_SETFL failed:" << qt_error_string(errno);
        ::close(fd);
        return;
    }

    this->mFd = fd;
    this->mNotifier = new QSocketNotifier(fd, QSocketNotifier::Read, this);

    connect(
        this->mNotifier, &QSocketNotifier::activated, this,
        &Devd::onSocketActivated
    );

    this->mNotifier->setEnabled(true);
    this->mConnected = true;
    emit this->connectedChanged();
    qCInfo(logDevd) << "Connected to" << path;
}

void Devd::onSocketActivated() {
    std::array<char, 8192> buf{};
    ssize_t n = 0;
    while ((n = ::read(this->mFd, buf.data(), buf.size() - 1)) > 0) {
        buf[static_cast<size_t>(n)] = '\0';

        const QByteArray line =
            QByteArray(buf.data(), static_cast<qsizetype>(n)).trimmed();

        if (!line.isEmpty()) {
            qCDebug(logDevd) << "event" << line;
            emit this->eventReceived(QString::fromUtf8(line));
        }
    }

    if (n < 0 && errno != EAGAIN && errno != EWOULDBLOCK) {
        qCWarning(logDevd) << "read error:" << qt_error_string(errno);
    }
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
}

} // namespace topbar::devd
