qml_module(topbar
    URI TopBar
    SOURCES
        version.cpp
    LIBRARIES
        Qt::Gui
        Qt::Quick
        Qt::Concurrent
)

if (DEVD)
    add_subdirectory(devd)
endif()

if (SYSTEM)
    if (CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
        add_subdirectory(system)
    endif()
endif()

if (NETWORK)
    add_subdirectory(network)
endif()

if (OSS)
    add_subdirectory(oss)
endif()

if (DWL)
    add_subdirectory(dwl)
endif()

target_include_directories(topbar PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/..
    ${CMAKE_CURRENT_BINARY_DIR}/..
)
