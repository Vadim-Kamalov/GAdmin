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

FetchContent_Declare(imgui  GIT_REPOSITORY https://github.com/ocornut/imgui.git)
FetchContent_Declare(kthook GIT_REPOSITORY https://github.com/defaultzone/kthook.git)

FetchContent_Declare(json
    GIT_REPOSITORY https://github.com/nlohmann/json.git

    # Bump step-security/harden-runner from 2.12.1 to 2.12.2 (#4837)
    GIT_TAG d33ecd3f3bd11e30aa8bbabb00e0a9cd3f2456d8
)

FetchContent_Declare(ctre
    GIT_REPOSITORY https://github.com/hanickadot/compile-time-regular-expressions.git

    # fix for changes in comparison in old compilers, failing in bug introduced lately (branch: main)
    GIT_TAG aa31a2537e6563c1792e9bef0fe2be7122c4a8ee
)

FetchContent_Declare(imgui_markdown
    GIT_REPOSITORY https://github.com/enkisoftware/imgui_markdown.git

    # Added dynamic font support to MarkdownHeadingFormat (branch: dev)
    GIT_TAG 3914f24ddd3a6369308efd48dfcace3bc6096783
)

FetchContent_MakeAvailable(json kthook imgui ctre imgui_markdown)
