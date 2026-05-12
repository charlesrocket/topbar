#pragma once

#include "device.hpp"
#include "enums.hpp"
#include "model.hpp"
#include "network.hpp"

#include <qobject.h>
#include <qproperty.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>
#include <qtypes.h>

namespace topbar::network {

class WifiNetwork : public Network {
    Q_OBJECT;
    QML_ELEMENT;
    QML_UNCREATABLE("WifiNetwork can only be acquired through WifiDevice");

    // clang-format off
	Q_PROPERTY(qreal signalStrength READ default NOTIFY signalStrengthChanged BINDABLE bindableSignalStrength);
	Q_PROPERTY(WifiSecurityType::Enum security READ default NOTIFY securityChanged BINDABLE bindableSecurity);
    // clang-format on

  public:
    explicit WifiNetwork(QString ssid, QObject *parent = nullptr);

    Q_INVOKABLE void connectWithPsk(const QString &psk);

    QBindable<qreal> bindableSignalStrength() { return &this->bSignalStrength; }
    QBindable<WifiSecurityType::Enum> bindableSecurity() {
        return &this->bSecurity;
    }

  signals:
    void requestConnectWithPsk(QString psk);
    void signalStrengthChanged();
    void securityChanged();

  private:
    // clang-format off
	Q_OBJECT_BINDABLE_PROPERTY(WifiNetwork, qreal, bSignalStrength, &WifiNetwork::signalStrengthChanged);
	Q_OBJECT_BINDABLE_PROPERTY(WifiNetwork, WifiSecurityType::Enum, bSecurity, &WifiNetwork::securityChanged);
    // clang-format on
};

///! WiFi variant of a @@NetworkDevice.
class WifiDevice : public NetworkDevice {
    Q_OBJECT;
    QML_ELEMENT;
    QML_UNCREATABLE("");

    // clang-format off
	Q_PROPERTY(UntypedObjectModel* networks READ networks CONSTANT);
	Q_PROPERTY(bool scannerEnabled READ scannerEnabled WRITE setScannerEnabled NOTIFY scannerEnabledChanged BINDABLE bindableScannerEnabled);
	Q_PROPERTY(WifiDeviceMode::Enum mode READ default NOTIFY modeChanged BINDABLE bindableMode);
    // clang-format on

  public:
    explicit WifiDevice(QObject *parent = nullptr);

    void networkAdded(WifiNetwork *net);
    void networkRemoved(WifiNetwork *net);

    // clang-format off
    [[nodiscard]] ObjectModel<WifiNetwork> *networks() {return &this->mNetworks;}
    QBindable<bool> bindableScannerEnabled() { return &this->bScannerEnabled; }
    [[nodiscard]] bool scannerEnabled() const { return this->bScannerEnabled; }
    void setScannerEnabled(bool enabled);
    QBindable<WifiDeviceMode::Enum> bindableMode() { return &this->bMode; }
    // clang-format on

  signals:
    void modeChanged();
    void scannerEnabledChanged(bool enabled);

  private:
    ObjectModel<WifiNetwork> mNetworks{this};
    Q_OBJECT_BINDABLE_PROPERTY(
        WifiDevice, bool, bScannerEnabled, &WifiDevice::scannerEnabledChanged
    );

    Q_OBJECT_BINDABLE_PROPERTY(
        WifiDevice, WifiDeviceMode::Enum, bMode, &WifiDevice::modeChanged
    );
};

}; // namespace topbar::network

QDebug operator<<(QDebug debug, const topbar::network::WifiNetwork *network);
QDebug operator<<(QDebug debug, const topbar::network::WifiDevice *device);
