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
)

target_link_libraries(topbar PRIVATE
    topbar-nullspace
)
