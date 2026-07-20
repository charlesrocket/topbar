wl_proto(wlp-dwl-ipc dwl-ipc-unstable-v2 "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}")

qt_add_library(topbar-dwl
    output.cpp
    tag.cpp
    manager.cpp
    qml.cpp
)

target_sources(topbar-dwl PRIVATE
    $<TARGET_OBJECTS:wlp-dwl-ipc>
)

qt_add_qml_module(topbar-dwl
    URI TopBar.DWL
    VERSION ${PROJECT_VERSION}
    TYPEINFO "topbar-dwl.qmltypes"
)

qt_query_qml_module(topbar-dwl
    PLUGIN_TARGET dwl_plugin_target
    TARGET_PATH  dwl_target_path
    QMLDIR       dwl_qmldir
    TYPEINFO     dwl_typeinfo
)

set(dwl_dir "${INSTALL_QMLDIR}/${dwl_target_path}")

install(TARGETS topbar-dwl
    LIBRARY DESTINATION "${dwl_dir}"
    RUNTIME DESTINATION "${dwl_dir}"
    ARCHIVE DESTINATION "${dwl_dir}"
)

install(TARGETS "${dwl_plugin_target}"
    LIBRARY DESTINATION "${dwl_dir}"
    RUNTIME DESTINATION "${dwl_dir}"
    ARCHIVE DESTINATION "${dwl_dir}"
)

install(FILES "${dwl_qmldir}"  DESTINATION "${dwl_dir}")
install(FILES "${dwl_typeinfo}" DESTINATION "${dwl_dir}")

if(ENABLE_PCH)
    target_precompile_headers(topbar-dwl PRIVATE
        <cstdint>
        <qlogging.h>
        <qlist.h>
        <qobject.h>
        <qstring.h>
        <qlist.h>
        <qtmetamacros.h>
        <qwaylandclientextension.h>
        <qscreen.h>
    )
endif()

target_link_libraries(topbar-dwl PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Wayland::Client
    wlp-dwl-ipc
)

target_link_libraries(topbar PRIVATE
    topbar-dwl
)
