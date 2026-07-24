message(STATUS "Distributor: ${DISTRIBUTOR}")
message(STATUS "QML directory: ${CMAKE_INSTALL_PREFIX}/${INSTALL_QMLDIR}")
message(STATUS "XDG directory: ${INSTALL_XDGDIR}")
message(STATUS "Library directory: ${INSTALL_LIBDIR}")

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

pkg_get_variable(WAYLAND_PROTOCOLS wayland-protocols pkgdatadir)

if(WAYLAND_PROTOCOLS)
    message(STATUS "Found Wayland protocols: ${WAYLAND_PROTOCOLS}")
else()
    message(FATAL_ERROR "Could not find wayland protocols")
endif()

set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml")

qt_standard_project_setup(REQUIRES 6.10)

add_subdirectory(src)
