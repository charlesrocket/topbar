#pragma once

#include "device.hpp"
#include "enums.hpp"
#include "model.hpp"

#include <qobject.h>
#include <qproperty.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>

namespace topbar::network {

class NetworkBackend : public QObject {
    Q_OBJECT;

  public:
    [[nodiscard]] virtual bool isAvailable() const = 0;

  protected:
    explicit NetworkBackend(QObject *parent = nullptr) : QObject(parent) {};
};

class Networking : public QObject {
    Q_OBJECT;

  public:
    static Networking *instance();

    void checkConnectivity();

    // clang-format off
    [[nodiscard]] ObjectModel<NetworkDevice> *devices() { return &this->mDevices; }
    [[nodiscard]] NetworkBackendType::Enum backend() const { return this->mBackendType; }
    QBindable<bool> bindableWifiEnabled() { return &this->bWifiEnabled; }
    [[nodiscard]] bool wifiEnabled() const { return this->bWifiEnabled; }
    void setWifiEnabled(bool enabled);
    QBindable<bool> bindableWifiHardwareEnabled() { return &this->bWifiHardwareEnabled; }
    QBindable<bool> bindableCanCheckConnectivity() { return &this->bCanCheckConnectivity; }
    QBindable<bool> bindableConnectivityCheckEnabled() { return &this->bConnectivityCheckEnabled; }
    [[nodiscard]] bool connectivityCheckEnabled() const { return this->bConnectivityCheckEnabled; }
    void setConnectivityCheckEnabled(bool enabled);
    QBindable<NetworkConnectivity::Enum> bindableConnectivity() { return &this->bConnectivity; }
    // clang-format on

  signals:
    void requestSetWifiEnabled(bool enabled);
    void requestSetConnectivityCheckEnabled(bool enabled);
    void requestCheckConnectivity();

    void wifiEnabledChanged();
    void wifiHardwareEnabledChanged();
    void canCheckConnectivityChanged();
    void connectivityCheckEnabledChanged();
    void connectivityChanged();

  private slots:
    void deviceAdded(NetworkDevice *dev);
    void deviceRemoved(NetworkDevice *dev);

  private:
    explicit Networking(QObject *parent = nullptr);

    ObjectModel<NetworkDevice> mDevices{this};
    NetworkBackend *mBackend = nullptr;
    NetworkBackendType::Enum mBackendType = NetworkBackendType::None;
    // clang-format off
	Q_OBJECT_BINDABLE_PROPERTY(Networking, bool, bWifiEnabled, &Networking::wifiEnabledChanged);
	Q_OBJECT_BINDABLE_PROPERTY(Networking, bool, bWifiHardwareEnabled, &Networking::wifiHardwareEnabledChanged);
	Q_OBJECT_BINDABLE_PROPERTY(Networking, bool, bCanCheckConnectivity, &Networking::canCheckConnectivityChanged);
	Q_OBJECT_BINDABLE_PROPERTY(Networking, bool, bConnectivityCheckEnabled, &Networking::connectivityCheckEnabledChanged);
	Q_OBJECT_BINDABLE_PROPERTY(Networking, NetworkConnectivity::Enum, bConnectivity, &Networking::connectivityChanged);
    // clang-format on
};

class NetworkingQml : public QObject {
    Q_OBJECT;
    QML_NAMED_ELEMENT(Networking);
    QML_SINGLETON;
    // clang-format off
	Q_PROPERTY(UntypedObjectModel* devices READ devices CONSTANT);
	Q_PROPERTY(topbar::network::NetworkBackendType::Enum backend READ backend CONSTANT);
	Q_PROPERTY(bool wifiEnabled READ wifiEnabled WRITE setWifiEnabled NOTIFY wifiEnabledChanged);
	Q_PROPERTY(bool wifiHardwareEnabled READ default NOTIFY wifiHardwareEnabledChanged BINDABLE bindableWifiHardwareEnabled);
	Q_PROPERTY(bool canCheckConnectivity READ default NOTIFY canCheckConnectivityChanged BINDABLE bindableCanCheckConnectivity);
	Q_PROPERTY(bool connectivityCheckEnabled READ connectivityCheckEnabled WRITE setConnectivityCheckEnabled NOTIFY connectivityCheckEnabledChanged);
	Q_PROPERTY(topbar::network::NetworkConnectivity::Enum connectivity READ default NOTIFY connectivityChanged BINDABLE bindableConnectivity);
    // clang-format on

  public:
    explicit NetworkingQml(QObject *parent = nullptr);

    Q_INVOKABLE static void checkConnectivity();

    // clang-format on
    [[nodiscard]] static ObjectModel<NetworkDevice> *devices() {
        return Networking::instance()->devices();
    }
    [[nodiscard]] static NetworkBackendType::Enum backend() {
        return Networking::instance()->backend();
    }
    [[nodiscard]] static bool wifiEnabled() {
        return Networking::instance()->wifiEnabled();
    }
    static void setWifiEnabled(bool enabled) {
        Networking::instance()->setWifiEnabled(enabled);
    }
    [[nodiscard]] static QBindable<bool> bindableWifiHardwareEnabled() {
        return Networking::instance()->bindableWifiHardwareEnabled();
    }
    [[nodiscard]] static QBindable<bool> bindableWifiEnabled() {
        return Networking::instance()->bindableWifiEnabled();
    }
    [[nodiscard]] static QBindable<bool> bindableCanCheckConnectivity() {
        return Networking::instance()->bindableCanCheckConnectivity();
    }
    [[nodiscard]] static bool connectivityCheckEnabled() {
        return Networking::instance()->connectivityCheckEnabled();
    }
    static void setConnectivityCheckEnabled(bool enabled) {
        Networking::instance()->setConnectivityCheckEnabled(enabled);
    }
    [[nodiscard]] static QBindable<NetworkConnectivity::Enum>
    bindableConnectivity() {
        return Networking::instance()->bindableConnectivity();
    }
    // clang-format off

  signals:
    void wifiEnabledChanged();
    void wifiHardwareEnabledChanged();
    void canCheckConnectivityChanged();
    void connectivityCheckEnabledChanged();
    void connectivityChanged();
};

class Network : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_UNCREATABLE("Network can only be aqcuired through networking devices");

    // clang-format off
	Q_PROPERTY(QString name READ name CONSTANT);
	Q_PROPERTY(bool connected READ default NOTIFY connectedChanged BINDABLE bindableConnected);
	Q_PROPERTY(bool known READ default NOTIFY knownChanged BINDABLE bindableKnown);
	Q_PROPERTY(ConnectionState::Enum state READ default NOTIFY stateChanged BINDABLE bindableState);
	Q_PROPERTY(bool stateChanging READ default NOTIFY stateChangingChanged BINDABLE bindableStateChanging);
    // clang-format on

  public:
    explicit Network(QString name, QObject *parent = nullptr);

    Q_INVOKABLE void connect();
    Q_INVOKABLE void disconnect();
    Q_INVOKABLE void forget();

    // clang-format off
	[[nodiscard]] QString name() const { return this->mName; }
	QBindable<bool> bindableConnected() { return &this->bConnected; }
	QBindable<bool> bindableKnown() { return &this->bKnown; }
	[[nodiscard]] ConnectionState::Enum state() const { return this->bState; }
	QBindable<ConnectionState::Enum> bindableState() { return &this->bState; }
	QBindable<bool> bindableStateChanging() { return &this->bStateChanging; }
    // clang-format on

  signals:
    void connectionFailed(ConnectionFailReason::Enum reason);
    void requestConnect();
    void connectedChanged();
    void knownChanged();
    void stateChanged();
    void stateChangingChanged();
    void requestDisconnect();
    void requestForget();

  protected:
    QString mName;

    // clang-format off
	Q_OBJECT_BINDABLE_PROPERTY(Network, bool, bConnected, &Network::connectedChanged);
	Q_OBJECT_BINDABLE_PROPERTY(Network, bool, bKnown, &Network::knownChanged);
	Q_OBJECT_BINDABLE_PROPERTY(Network, ConnectionState::Enum, bState, &Network::stateChanged);
	Q_OBJECT_BINDABLE_PROPERTY(Network, bool, bStateChanging, &Network::stateChangingChanged);
    // clang-format on
};

} // namespace topbar::network
