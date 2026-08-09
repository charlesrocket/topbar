qml_module(topbar-clients
    URI TopBar.Clients
    SOURCES github.cpp
    DEPENDENCIES QtQml
    LIBRARIES Qt::NetworkAuth Qt::Gui
)
