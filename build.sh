#!/bin/bash
#
# GAdmin - Script simplifying the work of administrators on the Gambit-RP
# Copyright (C) 2023-2024 The Contributors.
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
# SDPX-License-Identifier: GPL-3.0-only

# ========================================
# build.sh [TARGET] [--output [PARAMETER]]
# 
# TARGET:
#   debug   - Compile source with __GADMIN_DEBUG__ environment variable and with debug base-script.
#   release - Just compile source with release base-script.
# ========================================

if [ "$1" == "debug" ]; then
    __GADMIN_DEBUG__=1 clue -t=luajit --base "$PWD/base/Debug.lua" "$PWD/src/"
elif [ "$1" == "release" ]; then
    clue -t=luajit --base "$PWD/base/Release.lua" "$PWD/src/"
fi

# If we will use `--output` flag in commands above then it will print content of each file.

if ([ "$1" == "debug" ] || [ "$1" == "release" ]) && [ "$2" == "--output" ]; then
    mv "$PWD/main.lua" "$3"
fi
