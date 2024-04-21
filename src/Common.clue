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

local common = {}

/**
 * Read the contents of the file.
 * 
 * @param source string Path to the file to be read.
 * @return string       File contents.
 */
method common::readFileContent(source) {
    local handle, err = io.open(source, "r")
    if !err {
        local content = handle::read("*all")
        handle::close()
        return content
    } else {
        $debugWarning!("common::readFileContent", "catch error when trying to read some data from " .. source .. " file")
        $debugWarning!("common::readFileContent", "error: " .. err)
        return ""
    }
}

/** 
 * Write anything to a file.
 *
 * @param file string   Path to the file to be written to.
 * @param str string    The string to be written to the file.
 * @return void
 */
method common::writeInFile(source, str) {
    local handle, err = io.open(source, "w")
    if !err {
        handle::write(str)
        handle::close()
    } else {
        $debugWarning!("common::writeInFile", "catch error when trying to write some data in " .. source .. " file")
        $debugWarning!("common::writeInFile", "error: " .. err)
        self::sendScriptMessage("Произошла ошибка при записи в файл. Для подробной информации смотрите консоль SAMPFUNCS.")
    }
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
 * Convert `str` to lower case. Works on russian and english symbols.
 *
 * @param str string
 * @return string
 */
method common::toLowerCase(str) {
    str = string.gsub(u8::decode($), "([A-Z\192-\223Ё])", fn(c) {
        return string.char(string.byte(c) + ((c == 'ё') ? 16 : 32))
    })
    
    return u8(str)
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
 * @return boolean Wheather game is paused or not.
 */
method common::isGamePaused() {
    return isGamePaused() || receivedKillFocusEvent /* events.onWindowMessage */
}

/**
 * Send script message in SA:MP chat window.
 * 
 * @param message string
 * @return void
 */
method common::sendScriptMessage(message, ...) {
    sampAddChatMessage(string.format("[GAdmin v%s]:{FFFFFF} %s", $GADMIN_VERSION, string.format(message, ...)), 0xFF800000)
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

    r = (rgb >> 16) & 255
    g = (rgb >> 8) & 255
    b = rgb & 255
    a = (#hex == 6) ? alpha : ((rgb >> 24) & 255)

    return imgui.ImVec4(r / 255, g / 255, b / 255, a / 255)
}

return common
