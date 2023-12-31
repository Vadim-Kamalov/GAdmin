/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023-2024 The Contributors.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SDPX-License-Identifier: GPL-3.0-only
 */

@import "Assets" => assets

local common = {}

/**
 * Read the contents of the file.
 * 
 * @param source string Path to the file to be read.
 * @return string       File contents.
 */
method common::readFileContent(source) {
    local handle    = io.open(source, "r")
    local content   = handle::read("*all")
    handle::close()
    return content
}

/** 
 * Write anything to a file.
 *
 * @param file string   Path to the file to be written to.
 * @param str string    The string to be written to the file.
 * @return void
 */
method common::writeInFile(source, str) {
    local handle = io.open(source, "w")
    handle::write(str)
    handle::close()
}


/**
 * Create all directories (from working directory) in tree table if some of them doesn't exist.
 * All "/" characters in directory path will be replaced with "\\" character (UNIX path-style => Windows path-style).
 */
method common::makeDirectoryTree(tree) {
    for _, directory in tree {
        directory = string.gsub(directory, "/", "\\")
        if !doesDirectoryExist(getWorkingDirectory() .. "\\" .. directory) {
            createDirectory(getWorkingDirectory() .. "\\" .. directory)
        }
    }
}

/**
 * @return boolean Wheather cursor active or not.
 */
method common::isCursorActive() {
    return isCursorActive() || sampIsChatInputActive() || isSampfuncsConsoleActive() || sampIsDialogActive()
}

/**
 * @return boolean Wheather any input is active (including imgui InputText).
 */
method common::isInputsActive() {
    return sampIsChatInputActive() || isSampfuncsConsoleActive() || sampIsDialogActive() || imgui.GetIO().WantTextInput
}

/**
 * Translation of RGB (or RGBA) string color into ImVec4 format.
 *
 * @param hex string    RGB (or RGBA) represented as a string in decimal format.
 * @param alpha number  Last argument in ImVec4, by default it's `255`.
 * @return ImVec4
 */
method common::convertHex2ImVec4(hex, alpha = 255) {
    local rgb = tonumber(hex, 16)
    local r, g, b, a

    if (#hex == 6) {
        r = (rgb >> 16) & 255
        g = (rgb >> 8) & 255
        b = rgb & 255
        a = alpha
    } elseif (#hex == 8) {
        r, g, b, a = assets::explodeARGB(rgb) 
    }

    return imgui.ImVec4(r / 255, g / 255, b / 255, a / 255)
}

return common
