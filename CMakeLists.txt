# GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
# Copyright (C) 2023-2026 The Contributors.
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
project(gadmin VERSION 1.8.14 LANGUAGES CXX RC)

# We use the content of the JSON files from the `embed/` directory directly
# in the code by employing the `#embed` preprocessor directive from C++26.
# Converting these files to MessagePack format can reduce the binary size.
#
# It is recommended to enable this option when building for a release.
#
# This depends on the `mpk` command, which can be installed by running
# `cargo install msgpack-cli` or by installing it manually from its
# GitHub repository: https://github.com/pluots/mpk.
#
# After installation, please ensure that `mpk` is in your `PATH`.
option(USE_EMBEDDED_MESSAGE_PACK "Reduce binary size by converting JSON files to MessagePack format" OFF)

# UPX is an advanced executable file compressor. It can reduce the size
# of a binary by approximately 50%-70%, while preserving the same functionality as
# before. Note that it can significantly slow down the compilation time.
#
# It is recommended to enable this option when building for a release.
#
# This depends on the `upx` command, which can be installed from the
# latest release: https://github.com/upx/upx/releases/latest.
#
# After installation, please ensure that `upx` is in your `PATH`.
option(USE_UPX "Reduce binary size by applying UPX" OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS  ON)
set(CMAKE_SHARED_LIBRARY_PREFIX    "")
set(CMAKE_STATIC_LIBRARY_PREFIX    "")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

if (NOT ${PROJECT_NAME}_VERSION_PATCH)
    set(${PROJECT_NAME}_VERSION_PATCH 0)
endif()

include(cmake/fetch_content.cmake)

add_subdirectory(src/common) # Target: common
add_subdirectory(src/plugin) # Target: plugin
add_subdirectory(src/loader) # Target: loader
