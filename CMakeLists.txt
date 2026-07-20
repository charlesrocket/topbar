cmake_minimum_required(VERSION 3.20)
project(topbar VERSION 0.3.0)

set(DISTRIBUTOR "Source" CACHE STRING "Distributor")
set(ENABLE_PCH TRUE CACHE BOOL "Use PCH")
set(ENABLE_MODULES "components;plugin" CACHE STRING "Modules to build/install")
set(INSTALL_LIBDIR "lib/topbar" CACHE STRING "Library install directory")
set(INSTALL_QMLDIR "lib/qt6/qml" CACHE STRING "QML install directory")
set(INSTALL_XDGDIR "etc/xdg" CACHE STRING "XDG install directory")

if(UNIX)
    include_directories(/usr/local/include)
    link_directories(/usr/local/lib)
endif()

include(${CMAKE_SOURCE_DIR}/plugin/version.cmake)
include(${CMAKE_SOURCE_DIR}/plugin/util.cmake)

message(STATUS "XDG install directory: ${INSTALL_XDGDIR}")
message(STATUS "Library install directory: ${INSTALL_LIBDIR}")
message(STATUS "Distributor: ${DISTRIBUTOR}")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

boption(DEVD "Devd" ON)
boption(SYSTEM "System" ON)
boption(NETWORK "Network" ON REQUIRES DEVD)
boption(OSS "OSS" ON REQUIRES DEVD)
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

if("components" IN_LIST ENABLE_MODULES)
    install(
        DIRECTORY "${CMAKE_SOURCE_DIR}/components/"
        DESTINATION "${INSTALL_XDGDIR}/quickshell/topbar"
    )
endif()

if("plugin" IN_LIST ENABLE_MODULES)
    add_subdirectory(plugin)
endif()
