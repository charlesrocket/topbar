wl_proto(wlp-ns-ctl nullspace-controller-v1 "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}")

qml_module(topbar-nullspace
    URI TopBar.Nullspace
    SOURCES
        space.cpp
        ipc.cpp
        qml.cpp
    LIBRARIES
        Qt::Core
        Qt::Gui
        Qt::Widgets
        Qt::Network
        Wayland::Client
        wlp-ns-ctl
)

target_sources(topbar-nullspace PRIVATE
    $<TARGET_OBJECTS:wlp-ns-ctl>
)

target_link_libraries(topbar PRIVATE
    topbar-nullspace
)
