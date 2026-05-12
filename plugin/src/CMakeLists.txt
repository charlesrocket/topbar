find_package(Qt6 REQUIRED COMPONENTS
    ShaderTools
    Core
    Qml
    Gui
    Widgets
    WaylandClient
    Quick
    QuickControls2
    Concurrent
)

find_package(PkgConfig REQUIRED)
find_package(WaylandScanner REQUIRED)

find_program(WAYLAND_SCANNER_EXE
    NAMES wayland-scanner
    REQUIRED
)

find_program(QT_WAYLAND_SCANNER_EXE
    NAMES qtwaylandscanner
    HINTS "/usr/local/libexec/qt6"
    REQUIRED
)

set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml")
qt_standard_project_setup(REQUIRES 6.9)
add_library(topbar-pch INTERFACE)

if(NOT TARGET Wayland::Scanner)
    message(FATAL_ERROR "Wayland::Scanner target not found. You might be missing the WaylandScanner CMake package.")
endif()

pkg_get_variable(WAYLAND_PROTOCOLS wayland-protocols pkgdatadir)

if(WAYLAND_PROTOCOLS)
    message(STATUS "Found wayland protocols at ${WAYLAND_PROTOCOLS}")
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
        version.hpp
    LIBRARIES
        Qt::Gui
        Qt::Quick
        Qt::Concurrent
)

add_subdirectory(network)
add_subdirectory(oss)
add_subdirectory(dwl)

target_include_directories(topbar PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/..
    ${CMAKE_CURRENT_BINARY_DIR}/..
)
