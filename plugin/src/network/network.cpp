#include "network.hpp"

#include "backend.hpp"
#include "device.hpp"
#include "enums.hpp"

#include <qdebug.h>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qstring.h>
#include <qtmetamacros.h>
#include <utility>

namespace topbar::network {

namespace {
Q_LOGGING_CATEGORY(logNetwork, "topbar.network");
} // namespace

Networking::Networking(QObject *parent) : QObject(parent) {
    auto *freebsd = new FreeBSDBackend(this);
    if (freebsd->isAvailable()) {
        QObject::connect(
            freebsd, &FreeBSDBackend::deviceAdded, this,
            &Networking::deviceAdded
        );

        QObject::connect(
            freebsd, &FreeBSDBackend::deviceRemoved, this,
            &Networking::deviceRemoved
        );

        QObject::connect(
            this, &Networking::requestSetWifiEnabled, freebsd,
            &FreeBSDBackend::setWifiEnabled
        );

        this->bindableWifiEnabled().setBinding([freebsd]() {
            return freebsd->wifiEnabled();
        });

        this->bindableWifiHardwareEnabled().setBinding([freebsd]() {
            return freebsd->wifiHardwareEnabled();
        });

        this->mBackend = freebsd;
        this->mBackendType = NetworkBackendType::FreeBSD;
        qCInfo(logNetwork) << "Using FreeBSD network backend";
        return;
    } else {
        delete freebsd;
    }

    qCCritical(logNetwork) << "Network will not work, no backend detected";
}

Networking *Networking::instance() {
    static Networking *instance = new Networking(); // NOLINT
    return instance;
}

void Networking::deviceAdded(NetworkDevice *dev) {
    this->mDevices.insertObject(dev);
}
void Networking::deviceRemoved(NetworkDevice *dev) {
    this->mDevices.removeObject(dev);
}

void Networking::checkConnectivity() {
    if (!this->bConnectivityCheckEnabled || !this->bCanCheckConnectivity)
        return;
    emit this->requestCheckConnectivity();
}

void Networking::setWifiEnabled(bool enabled) {
    if (this->bWifiEnabled == enabled) return;
    emit this->requestSetWifiEnabled(enabled);
}

void Networking::setConnectivityCheckEnabled(bool enabled) {
    if (this->bConnectivityCheckEnabled == enabled) return;
    emit this->requestSetConnectivityCheckEnabled(enabled);
}

NetworkingQml::NetworkingQml(QObject *parent) : QObject(parent) {
    // clang-format off
	QObject::connect(Networking::instance(), &Networking::wifiEnabledChanged, this, &NetworkingQml::wifiEnabledChanged);
	QObject::connect(Networking::instance(), &Networking::wifiHardwareEnabledChanged, this, &NetworkingQml::wifiHardwareEnabledChanged);
	QObject::connect(Networking::instance(), &Networking::canCheckConnectivityChanged, this, &NetworkingQml::canCheckConnectivityChanged);
	QObject::connect(Networking::instance(), &Networking::connectivityCheckEnabledChanged, this, &NetworkingQml::connectivityCheckEnabledChanged);
	QObject::connect(Networking::instance(), &Networking::connectivityChanged, this, &NetworkingQml::connectivityChanged);
    // clang-format on
}

void NetworkingQml::checkConnectivity() {
    Networking::instance()->checkConnectivity();
}

Network::Network(QString name, QObject *parent)
    : QObject(parent), mName(std::move(name)) {
    this->bStateChanging.setBinding([this] {
        auto state = this->bState.value();
        return state == ConnectionState::Connecting
            || state == ConnectionState::Disconnecting;
    });
};

void Network::connect() {
    if (this->bConnected) {
        qCCritical(logNetwork) << this << "is already connected.";
        return;
    }

    this->requestConnect();
}

void Network::disconnect() {
    if (!this->bConnected) {
        qCCritical(logNetwork) << this << "is not currently connected";
        return;
    }

    this->requestDisconnect();
}

void Network::forget() { this->requestForget(); }

} // namespace topbar::network
