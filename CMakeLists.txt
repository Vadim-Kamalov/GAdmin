cmake_minimum_required(VERSION 3.27)
project(GAdmin VERSION 0.0 LANGUAGES CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

file(GLOB_RECURSE SOURCES src/*.cpp)
add_library(${PROJECT_NAME} SHARED ${SOURCES})
include(cmake/libraries.cmake)

include(cmake/compile_flags.cmake)
target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_link_libraries(${PROJECT_NAME} PRIVATE -lstdc++exp ${LIBRARIES_LINKAGE})
set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME ${PROJECT_NAME} SUFFIX ".asi")
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_23)
