qml_module(topbar-oss
    URI TopBar.OSS
    SOURCES oss.cpp
    DEPENDENCIES QtQml
    LIBRARIES
        Qt::Core
        topbar-devd
)
