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
project(gadmin VERSION 0.0 LANGUAGES CXX RC)

set(CMAKE_EXPORT_COMPILE_COMMANDS  ON)
set(CMAKE_SHARED_LIBRARY_PREFIX    "")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

if (NOT gadmin_VERSION_PATCH)
    set(gadmin_VERSION_PATCH 0)
endif()

include(cmake/fetch_content.cmake)
add_subdirectory(src/common)
add_subdirectory(src/plugin)
add_subdirectory(src/loader)
