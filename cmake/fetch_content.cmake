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

include(FetchContent)

FetchContent_Declare(imgui
    GIT_REPOSITORY https://github.com/ocornut/imgui.git

    # Backends: OpenGL3: call ImGui_ImplOpenGL3_InitLoader() in
    # ImGui_ImplOpenGL3_CreateDeviceObjects() / ImGui_ImplOpenGL3_DestroyDeviceObjects(). (#9112)
    GIT_TAG 69a501df6e6887a074b3c17a1c1bdd40a4c06dee
)

FetchContent_Declare(kthook
    GIT_REPOSITORY https://github.com/defaultzone/kthook.git

    # fix(warning): 'thiscall' attribute is used for non-class method in kthook_x86_64_detail.hpp:42:42
    GIT_TAG 4bac72d0ab429a46449b5827bc2342cebb4a590c
)

FetchContent_Declare(json
    GIT_REPOSITORY https://github.com/nlohmann/json.git

    # Bump step-security/harden-runner from 2.12.1 to 2.12.2 (#4837)
    GIT_TAG d33ecd3f3bd11e30aa8bbabb00e0a9cd3f2456d8
)

FetchContent_Declare(ctre
    GIT_REPOSITORY https://github.com/hanickadot/compile-time-regular-expressions.git

    # fix for overly sensitive gcc
    GIT_TAG 6225211806c48230e5d17a1e555ef69e7325051c
)

FetchContent_Declare(imgui_markdown
    GIT_REPOSITORY https://github.com/defaultzone/imgui_markdown.git

    # fix(warning): unused variable 'style' in ImGui::Markdown
    GIT_TAG 8fa932f0dd94f38e92bbe33072766c9fad35cbe7
)

FetchContent_MakeAvailable(json kthook imgui ctre imgui_markdown)
