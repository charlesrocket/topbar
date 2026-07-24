add_executable(instance
    instance.cpp
)

target_include_directories(instance PRIVATE
    ${CMAKE_SOURCE_DIR}/plugin/src/devd
)

target_link_libraries(instance PRIVATE
    Qt::Core
    Qt::Qml
    Qt::Quick
    Qt::Test
    topbar-devd
)

add_test(NAME "instance" COMMAND instance)

set_tests_properties(instance PROPERTIES ENVIRONMENT
    "QML2_IMPORT_PATH=${CMAKE_BINARY_DIR}/qml"
)
