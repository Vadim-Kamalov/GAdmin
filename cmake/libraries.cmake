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

target_include_directories(${PROJECT_NAME} PUBLIC
    ${imgui_SOURCE_DIR}/
    ${kthook_SOURCE_DIR}/include/
    ${ctre_SOURCE_DIR}/include/
    ${imgui_markdown_SOURCE_DIR}/
)

target_sources(${PROJECT_NAME} PUBLIC
    ${imgui_SOURCE_DIR}/imgui.cpp
    ${imgui_SOURCE_DIR}/imgui_demo.cpp
    ${imgui_SOURCE_DIR}/imgui_draw.cpp
    ${imgui_SOURCE_DIR}/imgui_tables.cpp
    ${imgui_SOURCE_DIR}/imgui_widgets.cpp
    ${imgui_SOURCE_DIR}/misc/cpp/imgui_stdlib.cpp
    ${imgui_SOURCE_DIR}/backends/imgui_impl_win32.cpp
    ${imgui_SOURCE_DIR}/backends/imgui_impl_dx9.cpp
)

set(LIBRARIES_LINKAGE
    d3d9
    d3dx9
    kthook
    gdi32
    dwmapi
    common
    dbghelp
    rpcrt4
    nlohmann_json::nlohmann_json
    ctre::ctre
)
