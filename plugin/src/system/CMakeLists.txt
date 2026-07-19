qt_add_qml_module(topbar-system
    URI TopBar.System
    VERSION ${PROJECT_VERSION}
    SOURCES system.cpp
    DEPENDENCIES QtQml
)

install_qml_module(topbar-system)

target_include_directories(topbar-system PRIVATE
    ${CMAKE_BINARY_DIR}/plugin
)

target_link_libraries(topbar-system PRIVATE Qt6::Core)
