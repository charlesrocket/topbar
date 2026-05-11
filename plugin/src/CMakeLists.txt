find_package(Qt6 REQUIRED COMPONENTS
    ShaderTools
    Core
    Qml
    Gui
    GuiPrivate
    Widgets
    WaylandClient
    WaylandClientPrivate
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

function(qml_module arg_TARGET)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "URI" "SOURCES;QML_FILES;LIBRARIES")

    qt_add_qml_module(${arg_TARGET}
        URI ${arg_URI}
        VERSION ${VERSION}
        SOURCES ${arg_SOURCES}
        QML_FILES ${arg_QML_FILES}
    )

    qt_query_qml_module(${arg_TARGET}
        URI module_uri
        VERSION module_version
        PLUGIN_TARGET module_plugin_target
        TARGET_PATH module_target_path
        QMLDIR module_qmldir
        TYPEINFO module_typeinfo
    )

    message(STATUS "Created QML module ${module_uri}, version ${module_version}")

    set(module_dir "${INSTALL_QMLDIR}/${module_target_path}")
    install(TARGETS ${arg_TARGET} LIBRARY DESTINATION "${module_dir}" RUNTIME DESTINATION "${module_dir}" ARCHIVE DESTINATION "${module_dir}")
    install(TARGETS "${module_plugin_target}" LIBRARY DESTINATION "${module_dir}" RUNTIME DESTINATION "${module_dir}" ARCHIVE DESTINATION "${module_dir}")
    install(FILES "${module_qmldir}" DESTINATION "${module_dir}")
    install(FILES "${module_typeinfo}" DESTINATION "${module_dir}")

    target_link_libraries(${arg_TARGET} PRIVATE Qt::Core Qt::Qml ${arg_LIBRARIES})
endfunction()

function(wl_proto target name dir)
    set(PROTO_BUILD_PATH ${CMAKE_CURRENT_BINARY_DIR}/wl-proto/${name})
    make_directory(${PROTO_BUILD_PATH})

    set(WS_CLIENT_HEADER "${PROTO_BUILD_PATH}/wayland-${name}-client-protocol.h")
    set(WS_CLIENT_CODE   "${PROTO_BUILD_PATH}/wayland-${name}.c")
    set(QWS_CLIENT_HEADER "${PROTO_BUILD_PATH}/qwayland-${name}.h")
    set(QWS_CLIENT_CODE   "${PROTO_BUILD_PATH}/qwayland-${name}.cpp")
    set(PATH "${dir}/${name}.xml")

    add_custom_command(
        OUTPUT "${WS_CLIENT_HEADER}"
        COMMAND Wayland::Scanner client-header "${PATH}" "${WS_CLIENT_HEADER}"
        DEPENDS Wayland::Scanner "${PATH}"
    )

    add_custom_command(
        OUTPUT "${WS_CLIENT_CODE}"
        COMMAND Wayland::Scanner private-code "${PATH}" "${WS_CLIENT_CODE}"
        DEPENDS Wayland::Scanner "${PATH}"
    )

    add_custom_command(
        OUTPUT "${QWS_CLIENT_HEADER}"
        COMMAND Qt6::qtwaylandscanner client-header "${PATH}" > "${QWS_CLIENT_HEADER}"
        DEPENDS Qt6::qtwaylandscanner "${PATH}"
    )

    add_custom_command(
        OUTPUT "${QWS_CLIENT_CODE}"
        COMMAND Qt6::qtwaylandscanner client-code "${PATH}" > "${QWS_CLIENT_CODE}"
        DEPENDS Qt6::qtwaylandscanner "${PATH}"
    )

    add_library(${target} OBJECT
        ${WS_CLIENT_HEADER}
        ${WS_CLIENT_CODE}
        ${QWS_CLIENT_HEADER}
        ${QWS_CLIENT_CODE}
    )

    target_include_directories(${target} PUBLIC ${PROTO_BUILD_PATH})
    target_compile_options(${target} PRIVATE ${wayland_CFLAGS})
    target_link_libraries(${target} PUBLIC
        Qt6::WaylandClient
        Qt6::WaylandClientPrivate
    )
endfunction()

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

add_subdirectory(dwl)
add_subdirectory(oss)

target_include_directories(topbar PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/..
    ${CMAKE_CURRENT_BINARY_DIR}/..
)
