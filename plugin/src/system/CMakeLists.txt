qml_module(topbar-system
    URI TopBar.System
    SOURCES system.cpp
    DEPENDENCIES QtQml
    LIBRARIES Qt::Core
)

target_include_directories(topbar-system PRIVATE
    ${CMAKE_BINARY_DIR}/plugin
)
