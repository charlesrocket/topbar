find_package(Qt6 REQUIRED COMPONENTS
    Core
    Qml
    Gui
    Widgets
    WaylandClient
    Quick
    QuickControls2
    Concurrent
    Test
)

find_package(PkgConfig REQUIRED)
find_package(WaylandScanner REQUIRED)

find_program(WAYLAND_SCANNER_EXE
    NAMES wayland-scanner
    REQUIRED
)

find_program(QT_WAYLAND_SCANNER_EXE
    NAMES qtwaylandscanner
    HINTS
        "/usr/local/libexec/qt6"
        "/usr/lib/qt6/libexec"
    REQUIRED
)

set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml")
qt_standard_project_setup(REQUIRES 6.10)
add_library(topbar-pch INTERFACE)
pkg_get_variable(WAYLAND_PROTOCOLS wayland-protocols pkgdatadir)

if(WAYLAND_PROTOCOLS)
    message(STATUS "Found Wayland protocols: ${WAYLAND_PROTOCOLS}")
else()
	  message(FATAL_ERROR "Could not find wayland protocols")
endif()

target_precompile_headers(topbar-pch INTERFACE
    <qobject.h>
    <qqmlintegration.h>
    <qstring.h>
    <qqmlengine.h>
    <qloggingcategory.h>
    <qvariant.h>
    <qtimer.h>
    <qdir.h>
    <qlist.h>
    <qstringlist.h>
    <qpointer.h>
)

qml_module(topbar
    URI TopBar
    SOURCES
        version.cpp
    LIBRARIES
        Qt6::Gui
        Qt6::Quick
        Qt6::Concurrent
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
