#include "enums.hpp"

#include <qstring.h>

using namespace Qt::StringLiterals;

namespace topbar::network {

QString NetworkConnectivity::toString(NetworkConnectivity::Enum conn) {
    switch (conn) {
            // clang-format off
        case Unknown: return u"Unknown"_s;
        case None: return u"Not connected to a network"_s;
        case Portal: return u"Connection intercepted by a captive portal"_s;
        case Limited: return u"Partial internet connectivity"_s;
        case Full: return u"Full internet connectivity"_s;
        default: return u"Unknown"_s;
            // clang-format on
    }
}

QString NetworkBackendType::toString(NetworkBackendType::Enum type) {
    switch (type) {
        case NetworkBackendType::None: return "None";
        case NetworkBackendType::NetworkManager: return "NetworkManager";
        default: return "Unknown";
    }
}

QString ConnectionState::toString(ConnectionState::Enum state) {
    switch (state) {
        case Unknown: return u"Unknown"_s;
        case Connecting: return u"Connecting"_s;
        case Connected: return u"Connected"_s;
        case Disconnecting: return u"Disconnecting"_s;
        case Disconnected: return u"Disconnected"_s;
        default: return u"Unknown"_s;
    }
}

QString ConnectionFailReason::toString(ConnectionFailReason::Enum reason) {
    switch (reason) {
            // clang-format off
        case Unknown: return u"Unknown"_s;
        case NoSecrets: return u"Secrets were required but not provided"_s;
        case WifiClientDisconnected: return u"Wi-Fi supplicant diconnected"_s;
        case WifiClientFailed: return u"Wi-Fi supplicant failed"_s;
        case WifiAuthTimeout: return u"Wi-Fi connection took too long to authenticate"_s;
        case WifiNetworkLost: return u"Wi-Fi network could not be found"_s;
        default: return u"Unknown"_s;
            // clang-format on
    }
}

QString DeviceType::toString(DeviceType::Enum type) {
    switch (type) {
        case None: return u"None"_s;
        case Wifi: return u"Wifi"_s;
        default: return u"Unknown"_s;
    }
}

QString WifiSecurityType::toString(WifiSecurityType::Enum type) {
    switch (type) {
        case Unknown: return u"Unknown"_s;
        case Wpa3SuiteB192: return u"WPA3 Suite B 192-bit"_s;
        case Sae: return u"WPA3"_s;
        case Wpa2Eap: return u"WPA2 Enterprise"_s;
        case Wpa2Psk: return u"WPA2"_s;
        case WpaEap: return u"WPA Enterprise"_s;
        case WpaPsk: return u"WPA"_s;
        case StaticWep: return u"WEP"_s;
        case DynamicWep: return u"Dynamic WEP"_s;
        case Leap: return u"LEAP"_s;
        case Owe: return u"OWE"_s;
        case Open: return u"Open"_s;
        default: return u"Unknown"_s;
    }
}

QString WifiDeviceMode::toString(WifiDeviceMode::Enum mode) {
    switch (mode) {
        case Unknown: return u"Unknown"_s;
        case AdHoc: return u"Ad-Hoc"_s;
        case Station: return u"Station"_s;
        case AccessPoint: return u"Access Point"_s;
        case Mesh: return u"Mesh"_s;
        default: return u"Unknown"_s;
    };
}

} // namespace topbar::network
