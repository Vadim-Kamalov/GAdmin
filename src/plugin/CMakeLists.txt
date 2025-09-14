# GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
# Copyright (C) 2023-2025 The Contributors.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# SPDX-License-Identifier: GPL-3.0-only

cmake_minimum_required(VERSION 4.0.0)
project(plugin VERSION ${gadmin_VERSION} LANGUAGES CXX RC)

set(SERVER_HOST_ADDRESS       "46.174.48.194")
set(SERVER_COMMAND_DELAY_MS   "800")
set(SERVER_NAME_TAGS_DISTANCE "20")
set(SERVER_MAX_PLAYERS        "600")
set(PROJECT_REPOSITORY        "https://github.com/Vadim-Kamalov/GAdmin/tree/plugin")
set(PROJECT_DATABASE          "https://raw.githubusercontent.com/Vadim-Kamalov/GAdmin/refs/heads/plugin")
set(PROJECT_COPYRIGHT_YEARS   "2023-2025")

configure_file(version.rc.in ${CMAKE_BINARY_DIR}/plugin_version.rc)
file(GLOB_RECURSE SOURCES *.cpp)

add_library(${PROJECT_NAME} SHARED
    ${SOURCES}
    ${CMAKE_BINARY_DIR}/plugin_version.rc
    ${CMAKE_SOURCE_DIR}/src/raknet/bit_stream.cpp
)

include(${CMAKE_SOURCE_DIR}/cmake/options/use_embedded_message_pack.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/options/use_upx.cmake)

include(${CMAKE_SOURCE_DIR}/cmake/libraries.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/compile_flags.cmake)

target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_SOURCE_DIR}/include)
set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "gadmin" SUFFIX ".dll")
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_26)
target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBRARIES_LINKAGE})

target_compile_definitions(${PROJECT_NAME} PRIVATE
    PROJECT_REPOSITORY="${PROJECT_REPOSITORY}"
    PROJECT_DATABASE="${PROJECT_DATABASE}"
    PROJECT_VERSION="${PROJECT_VERSION}"
    SERVER_HOST_ADDRESS="${SERVER_HOST_ADDRESS}"
    SERVER_COMMAND_DELAY_MS=${SERVER_COMMAND_DELAY_MS}
    SERVER_MAX_PLAYERS=${SERVER_MAX_PLAYERS}
    SERVER_NAME_TAGS_DISTANCE=${SERVER_NAME_TAGS_DISTANCE}
    PROJECT_COPYRIGHT_YEARS="${PROJECT_COPYRIGHT_YEARS}"
)
