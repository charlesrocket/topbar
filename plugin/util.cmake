function(qml_module arg_TARGET)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "URI"
        "SOURCES;QML_FILES;QML_SINGLETONS;DEPENDENCIES;IMPORTS;OPTIONAL_IMPORTS;DEFAULT_IMPORTS;LIBRARIES"
    )

    set_source_files_properties(${arg_QML_SINGLETONS}
        PROPERTIES QT_QML_SINGLETON_TYPE TRUE
    )

    qt_add_qml_module(${arg_TARGET}
        URI ${arg_URI}
        SOURCES ${arg_SOURCES}
        QML_FILES ${arg_QML_FILES} ${arg_QML_SINGLETONS}
        DEPENDENCIES ${arg_DEPENDENCIES}
        IMPORTS ${arg_IMPORTS}
        OPTIONAL_IMPORTS ${arg_OPTIONAL_IMPORTS}
        DEFAULT_IMPORTS ${arg_DEFAULT_IMPORTS}
    )

    qt_query_qml_module(${arg_TARGET}
        URI module_uri
        PLUGIN_TARGET module_plugin_target
        TARGET_PATH module_target_path
        QMLDIR module_qmldir
        TYPEINFO module_typeinfo
    )

    message(STATUS "Generated QML module: ${module_uri}")
    string(REPLACE "/" ";" uri_parts "${module_target_path}")
    list(GET uri_parts 0 top_level)

    set(backing_lib_dir "${INSTALL_QMLDIR}/${top_level}/lib")
    set(module_dir "${INSTALL_QMLDIR}/${module_target_path}")

    install(TARGETS ${arg_TARGET}
        LIBRARY DESTINATION "${backing_lib_dir}"
        RUNTIME DESTINATION "${backing_lib_dir}"
    )

    install(TARGETS "${module_plugin_target}"
        LIBRARY DESTINATION "${module_dir}"
        RUNTIME DESTINATION "${module_dir}"
    )

    install(FILES "${module_qmldir}" DESTINATION "${module_dir}")
    install(FILES "${module_typeinfo}" DESTINATION "${module_dir}")

    target_link_libraries(${arg_TARGET} PRIVATE
        topbar-pch
        Qt::Core
        Qt::Qml
        ${arg_LIBRARIES}
    )

    file(RELATIVE_PATH plugin_to_lib
        "/${module_target_path}" "/${top_level}/lib"
    )

    set_property(TARGET ${module_plugin_target} APPEND PROPERTY
        INSTALL_RPATH "$ORIGIN/${plugin_to_lib}"
    )
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
        COMMAND Qt::qtwaylandscanner client-header "${PATH}" > "${QWS_CLIENT_HEADER}"
        DEPENDS Qt::qtwaylandscanner "${PATH}"
    )

    add_custom_command(
        OUTPUT "${QWS_CLIENT_CODE}"
        COMMAND Qt::qtwaylandscanner client-code "${PATH}" > "${QWS_CLIENT_CODE}"
        DEPENDS Qt::qtwaylandscanner "${PATH}"
    )

    add_library(${target} OBJECT
        ${WS_CLIENT_HEADER}
        ${WS_CLIENT_CODE}
        ${QWS_CLIENT_HEADER}
        ${QWS_CLIENT_CODE}
    )

    target_include_directories(${target}
        PUBLIC ${PROTO_BUILD_PATH}
    )

    target_compile_options(${target}
        PRIVATE ${wayland_CFLAGS} -Wno-sign-conversion
    )

    target_link_libraries(${target} PUBLIC
        Qt::WaylandClient
    )
endfunction()

function (tb_add_link_dependencies target)
    set_property(
        TARGET ${target}
        APPEND PROPERTY INTERFACE_LINK_LIBRARIES
        ${ARGN}
    )
endfunction()

function (tb_append_qmldir target text)
    get_property(qmldir_content TARGET ${target}
        PROPERTY _qt_internal_qmldir_content
    )

    if ("${qmldir_content}" STREQUAL "")
        message(WARNING "qs_append_qmldir failed")
        return()
    endif()

    set_property(TARGET ${target} APPEND_STRING PROPERTY
        _qt_internal_qmldir_content ${text}
    )
endfunction()

function (tb_add_module_deps_light target)
    foreach (dep IN LISTS ARGN)
        string(APPEND qmldir_extra "depends ${dep}\n")
    endforeach()

    tb_append_qmldir(${target} "${qmldir_extra}")
endfunction()

function(boption VAR NAME DEFAULT)
    cmake_parse_arguments(PARSE_ARGV 3 arg "" "REQUIRES" "")

    option(${VAR} ${NAME} ${DEFAULT})

    set(STATUS "${VAR}_status")
    set(EFFECTIVE "${VAR}_effective")
    set(${STATUS} ${${VAR}})
    set(${EFFECTIVE} ${${VAR}})

    if (${${VAR}} AND DEFINED arg_REQUIRES)
        set(REQUIRED_EFFECTIVE "${arg_REQUIRES}_effective")

        if (NOT ${${REQUIRED_EFFECTIVE}})
            set(${STATUS} "OFF (Requires ${arg_REQUIRES})")
            set(${EFFECTIVE} OFF)
        endif()
    endif()

    set(${EFFECTIVE} "${${EFFECTIVE}}" PARENT_SCOPE)
    message(STATUS "${NAME}: ${${STATUS}}")
endfunction()
