qt_add_qml_module(topbar-oss
    URI TopBar.OSS
    VERSION ${PROJECT_VERSION}
    SOURCES oss.cpp
    DEPENDENCIES QtQml
)

install_qml_module(topbar-oss)

target_link_libraries(topbar-oss PRIVATE topbar-devd Qt6::Core)
