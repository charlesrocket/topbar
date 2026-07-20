#pragma once

#include "enums.hpp"

#include <qobject.h>
#include <qproperty.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>

namespace topbar::network {

class NetworkDevice : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_UNCREATABLE("Devices can only be acquired through Network");
    // clang-format off
	Q_PROPERTY(DeviceType::Enum type READ type CONSTANT);
	Q_PROPERTY(QString name READ name NOTIFY nameChanged BINDABLE bindableName);
	Q_PROPERTY(QString address READ address NOTIFY addressChanged BINDABLE bindableAddress);
	Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged BINDABLE bindableConnected);
	Q_PROPERTY(topbar::network::ConnectionState::Enum state READ state NOTIFY stateChanged BINDABLE bindableState);
	Q_PROPERTY(bool nmManaged READ nmManaged WRITE setNmManaged NOTIFY nmManagedChanged)
	Q_PROPERTY(bool autoconnect READ autoconnect WRITE setAutoconnect NOTIFY autoconnectChanged);
    // clang-format on

  public:
    explicit NetworkDevice(DeviceType::Enum type, QObject *parent = nullptr);

    Q_INVOKABLE void disconnect();

    [[nodiscard]] DeviceType::Enum type() const { return this->mType; }
    QBindable<QString> bindableName() { return &this->bName; }
    [[nodiscard]] QString name() const { return this->bName; }
    QBindable<QString> bindableAddress() { return &this->bAddress; }
    [[nodiscard]] QString address() const { return this->bAddress; }
    QBindable<bool> bindableConnected() { return &this->bConnected; }
    [[nodiscard]] bool connected() const { return this->bConnected; }
    QBindable<ConnectionState::Enum> bindableState() { return &this->bState; }
    [[nodiscard]] ConnectionState::Enum state() const { return this->bState; }
    QBindable<bool> bindableNmManaged() { return &this->bNmManaged; }
    [[nodiscard]] bool nmManaged() { return this->bNmManaged; }
    void setNmManaged(bool managed);
    QBindable<bool> bindableAutoconnect() { return &this->bAutoconnect; }
    [[nodiscard]] bool autoconnect() { return this->bAutoconnect; }
    void setAutoconnect(bool autoconnect);

  signals:
    void requestDisconnect();
    void requestSetAutoconnect(bool autoconnect);
    void requestSetNmManaged(bool managed);
    void nameChanged();
    void addressChanged();
    void connectedChanged();
    void stateChanged();
    void nmManagedChanged();
    void autoconnectChanged();

  private:
    DeviceType::Enum mType;
    // clang-format off
	Q_OBJECT_BINDABLE_PROPERTY(NetworkDevice, QString, bName, &NetworkDevice::nameChanged);
	Q_OBJECT_BINDABLE_PROPERTY(NetworkDevice, QString, bAddress, &NetworkDevice::addressChanged);
	Q_OBJECT_BINDABLE_PROPERTY(NetworkDevice, bool, bConnected, &NetworkDevice::connectedChanged);
	Q_OBJECT_BINDABLE_PROPERTY(NetworkDevice, ConnectionState::Enum, bState, &NetworkDevice::stateChanged);
	Q_OBJECT_BINDABLE_PROPERTY(NetworkDevice, bool, bNmManaged, &NetworkDevice::nmManagedChanged);
	Q_OBJECT_BINDABLE_PROPERTY(NetworkDevice, bool, bAutoconnect, &NetworkDevice::autoconnectChanged);
    // clang-format on
};

} // namespace topbar::network
