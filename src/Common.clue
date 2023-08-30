/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023 The Contributors.
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
method common::writeInFile(file, str) {
    local handle = io.open(source, "w")
    handle::write(str)
    handle::close()
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

    if (#hex == 6) {
        local r     = (rgb >> 16) & 255
        local g     = (rgb >> 8) & 255
        local b     = rgb & 255
        local a     = alpha
    } elseif (#hex == 8) {
        local r     = (rgb >> 24) & 255
        local g     = (rgb >> 16) & 255
        local b     = (rgb >> 8) & 255
        local a     = rbg & 255
    }

    return imgui.ImVec4(r / 255, g / 255, r / 255, a / 255)
}

return common
