qt_add_qml_module(topbar-system
    URI TopBar.System
    VERSION 0.1
    SOURCES system.cpp
    DEPENDENCIES QtQml
)

install_qml_module(topbar-system)

target_link_libraries(topbar PRIVATE Qt6::Core)
