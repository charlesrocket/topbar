set(INSTALL_QMLDIR "" CACHE STRING "QML install dir")
set(INSTALL_QML_PREFIX "" CACHE STRING "QML install prefix")

if ("${INSTALL_QMLDIR}" STREQUAL "" AND "${INSTALL_QML_PREFIX}" STREQUAL "")
    message(WARNING "INSTALL_QMLDIR/INSTALL_QML_PREFIX is not set. QML modules will not be installed.")
else()
    if ("${INSTALL_QMLDIR}" STREQUAL "")
   	    set(QML_FULL_INSTALLDIR "${CMAKE_INSTALL_PREFIX}/${INSTALL_QML_PREFIX}")
    else()
   	    set(QML_FULL_INSTALLDIR "${INSTALL_QMLDIR}")
    endif()

    message(STATUS "QML install directory: ${QML_FULL_INSTALLDIR}")
endif()

function(install_qml_module arg_TARGET)
    if (NOT DEFINED QML_FULL_INSTALLDIR)
        return()
    endif()

    qt_query_qml_module(${arg_TARGET}
        URI module_uri
        VERSION module_version
        PLUGIN_TARGET module_plugin_target
        TARGET_PATH module_target_path
        QMLDIR module_qmldir
        TYPEINFO module_typeinfo
        QML_FILES module_qml_files
        RESOURCES module_resources
    )

    set(module_dir "${QML_FULL_INSTALLDIR}/${module_target_path}")

    if (NOT TARGET "${module_plugin_target}")
        message(FATAL_ERROR "install_qml_modules called for a target without a plugin!")
    endif()

  	get_target_property(target_type "${arg_TARGET}" TYPE)

  	if (NOT "${target_type}" STREQUAL "STATIC_LIBRARY")
        install(
            TARGETS "${arg_TARGET}"
            LIBRARY DESTINATION "${module_dir}"
            RUNTIME DESTINATION "${module_dir}"
        )

        install(
            TARGETS "${module_plugin_target}"
            LIBRARY DESTINATION "${module_dir}"
            RUNTIME DESTINATION "${module_dir}"
        )
    endif()

    install(FILES "${module_qmldir}" DESTINATION "${module_dir}")
    install(FILES "${module_typeinfo}" DESTINATION "${module_dir}")

    list(LENGTH module_qml_files num_files)

    if (NOT "${module_qml_files}" MATCHES "NOTFOUND" AND ${num_files} GREATER 0)
        qt_query_qml_module(${arg_TARGET} QML_FILES_DEPLOY_PATHS qml_files_deploy_paths)
        math(EXPR last_index "${num_files} - 1")

        foreach(i RANGE 0 ${last_index})
            list(GET module_qml_files       ${i} src_file)
            list(GET qml_files_deploy_paths ${i} deploy_path)

            get_filename_component(dst_name "${deploy_path}" NAME)
            get_filename_component(dest_dir "${deploy_path}" DIRECTORY)

            install(FILES "${src_file}" DESTINATION "${module_dir}/${dest_dir}" RENAME "${dst_name}")
        endforeach()
    endif()

    list(LENGTH module_resources num_files)

    if (NOT "${module_resources}" MATCHES "NOTFOUND" AND ${num_files} GREATER 0)
        qt_query_qml_module(${arg_TARGET} RESOURCES_DEPLOY_PATHS resources_deploy_paths)
        math(EXPR last_index "${num_files} - 1")

        foreach(i RANGE 0 ${last_index})
        list(GET module_resources       ${i} src_file)
        list(GET resources_deploy_paths ${i} deploy_path)

        get_filename_component(dst_name "${deploy_path}" NAME)
        get_filename_component(dest_dir "${deploy_path}" DIRECTORY)

        install(FILES "${src_file}" DESTINATION "${module_dir}/${dest_dir}" RENAME "${dst_name}")
      endforeach()
    endif()
endfunction()

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
        Qt6::WaylandClientPrivate
        Qt6::WaylandClient
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
    get_property(qmldir_content TARGET ${target} PROPERTY _qt_internal_qmldir_content)

    if ("${qmldir_content}" STREQUAL "")
        message(WARNING "qs_append_qmldir depends on private Qt cmake code, which has broken.")
        return()
    endif()

    set_property(TARGET ${target} APPEND_STRING PROPERTY _qt_internal_qmldir_content ${text})
endfunction()

function (tb_add_module_deps_light target)
    foreach (dep IN LISTS ARGN)
        string(APPEND qmldir_extra "depends ${dep}\n")
    endforeach()

    tb_append_qmldir(${target} "${qmldir_extra}")
endfunction()
