#!/usr/bin/bash
#
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

PLUGINS_DOWNLOAD_URL="https://github.com/defaultzone/nsis-components/raw/refs/heads/main/x86-unicode-plugins"
OUTPUT_DIRECTORY="$(dirname "$0")/pre-build-out"

mkdir -p $OUTPUT_DIRECTORY
wget -O $OUTPUT_DIRECTORY/nsJSON.dll $PLUGINS_DOWNLOAD_URL/nsJSON.dll 
wget -O $OUTPUT_DIRECTORY/INetC.dll $PLUGINS_DOWNLOAD_URL/INetC.dll
