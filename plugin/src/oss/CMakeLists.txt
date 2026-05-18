qt_add_qml_module(topbar-oss
    URI TopBar.OSS
    VERSION 0.1
    SOURCES oss.cpp
    DEPENDENCIES QtQml
)

install_qml_module(topbar-oss)

target_link_libraries(topbar-oss PRIVATE topbar Qt6::Core)
