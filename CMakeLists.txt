cmake_minimum_required(VERSION 3.30)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(DISTRIBUTOR "Unset" CACHE STRING "Distributor")
set(ENABLE_MODULES "plugin" CACHE STRING "Modules to build/install")
set(INSTALL_LIBDIR "lib/topbar" CACHE STRING "Library install directory")
set(INSTALL_QMLDIR "lib/qt6/qml" CACHE STRING "QML install directory")

include(${CMAKE_SOURCE_DIR}/plugin/version.cmake)
include(${CMAKE_SOURCE_DIR}/plugin/util.cmake)
include_directories(/usr/local/include)
link_directories(/usr/local/lib)

project(topbar VERSION 0.2.0)

boption(SYSTEM "System" ON)
boption(NETWORK "Network" ON)
boption(OSS "OSS" ON)
boption(DWL "Mango" ON)

add_compile_options(
    -Wall -Wextra -Wpedantic -Wshadow -Wconversion
    -Wnull-dereference -Wdouble-promotion
    -Wformat=2 -Wfloat-equal -Woverloaded-virtual
    -Wsign-conversion -Wredundant-decls -Wswitch
    -Wunreachable-code -Wno-extra-semi
)

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    add_compile_options(-Wunused-lambda-capture)
endif()

add_subdirectory(plugin)
