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
#
# ========================================================================
#
# This file sets `COMPILE_INFO` definition to the target where the file
# gets applied. The compile info contains the timestamp (in hex) when the
# compilation was started and build information: debug or release, whether
# `USE_EMBEDDED_MESSAGE_PACK` and/or `USE_UPX` options are enabled.
#
# Writes the string in the `<build-info>+<timestamp>` format.
#
# =======================================================================

# Slightly improved version of https://stackoverflow.com/a/41740102
# that works with 8 bytes and removes leading zeros. Requires number
# to be > 0 (can be fixed but why? ${COMPILE_TIME} is always > 0).
function(number_to_hex number output)
    set(chars "0123456789abcdef")
    set(hex "")

    foreach(i RANGE 16)
        math(EXPR nibble "${number} & 15")
        string(SUBSTRING "${chars}" "${nibble}" 1 nibble_hex)
        set(hex "${nibble_hex}${hex}")
        math(EXPR number "${number} >> 4")
    endforeach()

    string(REGEX REPLACE "^0+" "" hex "${hex}")
    set("${output}" "${hex}" PARENT_SCOPE)
endfunction()

string(TIMESTAMP COMPILE_TIME "%s")
set(BUILD_INFO_NUM 0)

number_to_hex(${COMPILE_TIME} COMPILE_TIME_HEX)

if(CMAKE_BUILD_TYPE MATCHES "Release")
    math(EXPR BUILD_INFO_NUM "${BUILD_INFO_NUM} | 1")
endif()

if(USE_EMBEDDED_MESSAGE_PACK)
    math(EXPR BUILD_INFO_NUM "${BUILD_INFO_NUM} | 2")
endif()

if(USE_UPX)
    math(EXPR BUILD_INFO_NUM "${BUILD_INFO_NUM} | 4")
endif ()

target_compile_definitions(${PROJECT_NAME} PRIVATE
    -DCOMPILE_INFO="${BUILD_INFO_NUM}+${COMPILE_TIME_HEX}"
)
