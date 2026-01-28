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
#
# =====================================================================
# usage: ./build.sh [OPTION]
#
# options:
#   -h, --help      show this help message and exit
#   clean           delete the build/ directory
#   build           create build directories, download NSIS and plugins
#   make            compile gadmin-web-installer.exe
#   make --launch   launch the installer after compilation
# =====================================================================

SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"

BUILD_DIRECTORY="$SCRIPT_PATH/build"
SOURCES_DIRECTORY="$SCRIPT_PATH/src"
BINARY_DIRECTORY="$BUILD_DIRECTORY/bin"
PLUGINS_DIRECTORY="$BUILD_DIRECTORY/plugins"

NSIS_VERSION="3.11"
NSIS_MAKE_EXECUTABLE_PATH="$BUILD_DIRECTORY/nsis-$NSIS_VERSION/Bin/makensis.exe"

NSIS_DOWNLOAD_URL="https://altushost-swe.dl.sourceforge.net/project/nsis/NSIS%203/$NSIS_VERSION/nsis-$NSIS_VERSION.zip?viasf=1"
PLUGINS_DOWNLOAD_URL="https://github.com/defaultzone/nsis-components/raw/refs/heads/main/x86-unicode-plugins"

echo_bold() {
    [ -z "$NO_COLOR" ] && echo "$(tput bold)$1$(tput sgr0)" || echo "$1"
}

wine_makensis() {
    pushd "$SOURCES_DIRECTORY" || exit 1
    wine "$NSIS_MAKE_EXECUTABLE_PATH" main.nsi
    mv gadmin-web-installer.exe "$BINARY_DIRECTORY/"
    popd || exit 1
}

print_help() {
    echo_bold "usage: $0 [OPTION]"
    echo ""
    echo_bold "options:"
    echo -e "\t-h, --help\tshow this help message and exit"
    echo -e "\tclean\t\tdelete the build/ directory"
    echo -e "\tbuild\t\tcreate build directories, download NSIS and plugins"
    echo -e "\tmake\t\tcompile gadmin-web-installer.exe"
    echo -e "\tmake --launch\tlaunch the installer after compilation"
}

case "$1" in
    "-h" | "--help")
        print_help
        exit 0
    ;;

    "clean")
        echo_bold "Deleting the build/ directory..."
        rm -rf "$BUILD_DIRECTORY"
        echo_bold "Done!"
        exit 0
    ;;

    "build")
        echo_bold "Creating $BUILD_DIRECTORY, $BINARY_DIRECTORY, and $PLUGINS_DIRECTORY directories..."
        mkdir -p "$BUILD_DIRECTORY" "$PLUGINS_DIRECTORY" "$BINARY_DIRECTORY"

        echo_bold "Downloading NSIS and its plugins..."
        wget -O "$PLUGINS_DIRECTORY/nsJSON.dll" "$PLUGINS_DOWNLOAD_URL/nsJSON.dll"
        wget -O "$PLUGINS_DIRECTORY/INetC.dll" "$PLUGINS_DOWNLOAD_URL/INetC.dll"
        wget -O "$BUILD_DIRECTORY/nsis-$NSIS_VERSION.zip" "$NSIS_DOWNLOAD_URL"

        echo_bold "Extracting $BUILD_DIRECTORY/nsis-$NSIS_VERSION.zip..."
        unzip "$BUILD_DIRECTORY/nsis-$NSIS_VERSION.zip" -d "$BUILD_DIRECTORY"
        echo_bold "Done!"
    ;;

    "make")
        if [ ! -f "$NSIS_MAKE_EXECUTABLE_PATH" ]; then
            echo_bold "Failed to locate makensis.exe (expected at $NSIS_MAKE_EXECUTABLE_PATH)."
            echo_bold "Ensure you have run \"$0 build\" before using this option."
            exit 1
        fi

        echo_bold "Compiling gadmin-web-installer.exe..."

        if [ "$2" == "--launch" ]; then
            wine_makensis
            echo_bold "Launching gadmin-web-installer.exe (--launch option provided)..."
            wine "$BINARY_DIRECTORY/gadmin-web-installer.exe"
            echo_bold "Done!"
            exit 0
        fi

        wine_makensis
        echo_bold "Done!"
    ;;

    *)
        print_help
        exit 0
    ;;
esac

