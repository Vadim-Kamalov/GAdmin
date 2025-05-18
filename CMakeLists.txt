cmake_minimum_required(VERSION 4.0.0)
project(GAdmin VERSION 0.0 LANGUAGES CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(SERVER_HOST_ADDRESS           "46.174.48.194")
set(SERVER_COMMAND_DELAY_MS       "700")
set(SERVER_NAME_TAGS_DISTANCE     "20")
set(SERVER_MAX_PLAYERS            "600")
set(PROJECT_REPOSITORY            "https://github.com/Vadim-Kamalov/GAdmin/tree/plugin")
set(PROJECT_DATABASE              "https://raw.githubusercontent.com/Vadim-Kamalov/GAdmin/refs/heads/plugin")

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

file(GLOB_RECURSE SOURCES src/*.cpp)
add_library(${PROJECT_NAME} SHARED ${SOURCES})

include(cmake/libraries.cmake)
include(cmake/compile_flags.cmake)

target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBRARIES_LINKAGE})
set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME ${PROJECT_NAME} SUFFIX ".asi")
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_26)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    PROJECT_REPOSITORY="${PROJECT_REPOSITORY}"
    PROJECT_DATABASE="${PROJECT_DATABASE}"
    PROJECT_VERSION="${PROJECT_VERSION}"
    SERVER_HOST_ADDRESS="${SERVER_HOST_ADDRESS}"
    SERVER_COMMAND_DELAY_MS=${SERVER_COMMAND_DELAY_MS}
    SERVER_MAX_PLAYERS=${SERVER_MAX_PLAYERS}
    SERVER_NAME_TAGS_DISTANCE=${SERVER_NAME_TAGS_DISTANCE}
)
