qt_add_qml_module(topbar-devd
    URI TopBar.Devd
    VERSION 0.1
    SOURCES devd.cpp
    DEPENDENCIES QtQml
)

install_qml_module(topbar-devd)

target_link_libraries(topbar-devd PRIVATE Qt6::Core)

if(TESTING)
    add_subdirectory(test)
endif()
