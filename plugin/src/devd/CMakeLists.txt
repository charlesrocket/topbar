qml_module(topbar-devd
    URI TopBar.Devd
    SOURCES devd.cpp
    DEPENDENCIES QtQml
)

if(TESTING)
    add_subdirectory(test)
endif()
