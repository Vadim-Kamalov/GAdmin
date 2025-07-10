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

if (NOT ${CMAKE_C_COMPILER_ID} STREQUAL "GNU" OR NOT ${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
    message(FATAL_ERROR "The C or C++ compiler is not GCC. Please set the C and C++ compilers to GCC.")
endif()

set(CMAKE_CXX_FLAGS_DEBUG "-g -O0")

# O1, O2, and O3 optimization levels cause undefined behavior when compiling for cxx_std_26.
# At some functions, for example, the ClickWarp activation triggers a SIGSEGV at an unknown
# address (0x44F000000). Possibly, there is a bug in the compiler I am using: i686-w64-mingw32-g++ (v15.1.0).
set(CMAKE_CXX_FLAGS_RELEASE "-O0")

target_compile_options(${PROJECT_NAME} PRIVATE -ffunction-sections -fdata-sections -fmerge-all-constants)
target_link_options(${PROJECT_NAME} PRIVATE -Wl,--gc-sections -ffast-math -static -fno-stack-protector -Wl,--no-insert-timestamp)
target_link_options(${PROJECT_NAME} PRIVATE -Wl,--disable-runtime-pseudo-reloc -Wl,--large-address-aware)
   
if (NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_link_options(${PROJECT_NAME} PRIVATE -Wl,--strip-all -Wl,--exclude-all-symbols)
endif()

target_link_options(${PROJECT_NAME} PRIVATE -static-libgcc -static-libstdc++ -lstdc++exp)

# Bug 110572 - ld.lld: error: duplicate symbol: std::type_info::operator==(std::type_info const&) const
# See: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=110572
target_compile_options(${PROJECT_NAME} PRIVATE -fno-rtti)
