qml_module(topbar-clients
    URI TopBar.Clients
    SOURCES codeberg.cpp github.cpp
    DEPENDENCIES QtQml
    LIBRARIES Qt::NetworkAuth Qt::Gui Qt6Keychain::Qt6Keychain
)

target_compile_definitions(topbar-clients PRIVATE TOPBAR_CLIENTS_LIBRARY)
