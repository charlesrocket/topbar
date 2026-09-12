qml_module(topbar-mango
    URI TopBar.Mango
    SOURCES
        output.cpp
        tag.cpp
        manager.cpp
        qml.cpp
    LIBRARIES
        Qt::Core
        Qt::Gui
        Qt::Widgets
)

target_link_libraries(topbar PRIVATE
    topbar-mango
)
