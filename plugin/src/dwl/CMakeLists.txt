wl_proto(wlp-dwl-ipc dwl-ipc-unstable-v2 "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}")

qml_module(topbar-dwl
    URI TopBar.DWL
    SOURCES
        output.cpp
        tag.cpp
        manager.cpp
        qml.cpp
    LIBRARIES
        Qt::Core
        Qt::Gui
        Qt::Widgets
        Wayland::Client
        wlp-dwl-ipc
)

target_sources(topbar-dwl PRIVATE
    $<TARGET_OBJECTS:wlp-dwl-ipc>
)

target_link_libraries(topbar PRIVATE
    topbar-dwl
)
