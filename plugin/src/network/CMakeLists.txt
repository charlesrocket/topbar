qt_add_qml_module(topbar-network
    URI TopBar.Networking
    VERSION 0.1
    SOURCES
        backend.cpp
        network.cpp
        device.cpp
        wifi.cpp
        enums.cpp
        model.hpp
    DEPENDENCIES QtQml
)

install_qml_module(topbar-network)

target_link_libraries(topbar-network PRIVATE
    topbar-devd
    Qt6::Core
    Qt6::Qml
)
