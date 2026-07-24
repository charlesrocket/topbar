qml_module(topbar-network
    URI TopBar.Networking
    SOURCES
        backend.cpp
        network.cpp
        device.cpp
        wifi.cpp
        enums.cpp
        model.hpp
    LIBRARIES
        Qt::Core
        Qt::Qml
        topbar-devd
    DEPENDENCIES QtQml
)
