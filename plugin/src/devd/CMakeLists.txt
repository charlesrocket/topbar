qt_add_qml_module(topbar-devd
    URI TopBar.Devd
    VERSION ${PROJECT_VERSION}
    SOURCES devd.cpp
    DEPENDENCIES QtQml
)

install_qml_module(topbar-devd)

target_link_libraries(topbar-devd PRIVATE Qt6::Core)
