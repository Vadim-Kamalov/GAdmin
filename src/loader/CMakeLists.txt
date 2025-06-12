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
project(loader VERSION 1.0 LANGUAGES CXX)

set(ORIGINAL_FILENAME_TO_SEARCH "gadmin.dll")
set(UPDATE_REPOSITORY           "Vadim-Kamalov/GAdmin")

file(GLOB_RECURSE SOURCES *.cpp)
add_library(${PROJECT_NAME} SHARED ${SOURCES})

include(${CMAKE_SOURCE_DIR}/cmake/compile_flags.cmake)

target_link_libraries(${PROJECT_NAME} PRIVATE wininet version nlohmann_json::nlohmann_json common)
target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_SOURCE_DIR}/include)
set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "gadmin-loader" SUFFIX ".asi")
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_23)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    ORIGINAL_FILENAME_TO_SEARCH="${ORIGINAL_FILENAME_TO_SEARCH}"
    UPDATE_REPOSITORY="${UPDATE_REPOSITORY}"
)
