#pragma once

#include <qobject.h>
#include <qqmlintegration.h>
#include <qtypes.h>

namespace topbar::network {

class NetworkConnectivity : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_SINGLETON;

  public:
    enum Enum : quint8 {
        Unknown = 0,
        None = 1,
        Portal = 2,
        Limited = 3,
        Full = 4,
    };

    Q_ENUM(Enum);
    Q_INVOKABLE static QString toString(NetworkConnectivity::Enum conn);
};

class NetworkBackendType : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_SINGLETON;

  public:
    enum Enum : quint8 {
        None = 0,
        NetworkManager = 1,
        FreeBSD = 2,
    };

    Q_ENUM(Enum);
    Q_INVOKABLE static QString toString(NetworkBackendType::Enum type);
};

class ConnectionState : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_SINGLETON;

  public:
    enum Enum : quint8 {
        Unknown = 0,
        Connecting = 1,
        Connected = 2,
        Disconnecting = 3,
        Disconnected = 4,
    };

    Q_ENUM(Enum);
    Q_INVOKABLE static QString toString(ConnectionState::Enum state);
};

class ConnectionFailReason : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_SINGLETON;

  public:
    enum Enum : quint8 {
        Unknown = 0,
        NoSecrets = 1,
        WifiClientDisconnected = 2,
        WifiClientFailed = 3,
        WifiAuthTimeout = 4,
        WifiNetworkLost = 5,
    };

    Q_ENUM(Enum);
    Q_INVOKABLE static QString toString(ConnectionFailReason::Enum reason);
};

class DeviceType : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_SINGLETON;

  public:
    enum Enum : quint8 {
        None = 0,
        Wifi = 1,
    };

    Q_ENUM(Enum);
    Q_INVOKABLE static QString toString(DeviceType::Enum type);
};

class WifiSecurityType : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_SINGLETON;

  public:
    enum Enum : quint8 {
        Wpa3SuiteB192 = 0,
        Sae = 1,
        Wpa2Eap = 2,
        Wpa2Psk = 3,
        WpaEap = 4,
        WpaPsk = 5,
        StaticWep = 6,
        DynamicWep = 7,
        Leap = 8,
        Owe = 9,
        Open = 10,
        Unknown = 11,
    };

    Q_ENUM(Enum);
    Q_INVOKABLE static QString toString(WifiSecurityType::Enum type);
};

class WifiDeviceMode : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_SINGLETON;

  public:
    enum Enum : quint8 {
        AdHoc = 0,
        Station = 1,
        AccessPoint = 2,
        Mesh = 3,
        Unknown = 4,
    };

    Q_ENUM(Enum);
    Q_INVOKABLE static QString toString(WifiDeviceMode::Enum mode);
};

} // namespace topbar::network
