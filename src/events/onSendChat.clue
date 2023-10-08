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

@import "Config" => config

/**
 * Swap language layout from russian to english.
 * 
 * @param text string
 * @return string
 */
local fn swapLayout(text) {
    text = u8(text)

    for k, v of ({
        ["й"] = "q", ["ц"] = "w", ["у"] = "e", ["к"] = "r", ["е"] = "t",
        ["н"] = "y", ["г"] = "u", ["ш"] = "i", ["щ"] = "o", ["з"] = "p",
        ["х"] = "[", ["ъ"] = "]", ["ф"] = "a", ["ы"] = "s", ["в"] = "d",
        ["а"] = "f", ["п"] = "g", ["р"] = "h", ["о"] = "j", ["л"] = "k",
        ["д"] = "l", ["ж"] = ";", ["э"] = "'", ["я"] = "z", ["ч"] = "x",
        ["с"] = "c", ["м"] = "v", ["и"] = "b", ["т"] = "n", ["ь"] = "m",
        ["б"] = ",", ["ю"] = ".", ["Й"] = "Q", ["Ц"] = "Q", ["У"] = "W",
        ["К"] = "E", ["Е"] = "R", ["Н"] = "T", ["Г"] = "Y", ["Ш"] = "U",
        ["Щ"] = "I", ["З"] = "O", ["Х"] = "{", ["Ъ"] = "}", ["Ф"] = "A",
        ["Ы"] = "S", ["В"] = "D", ["А"] = "F", ["П"] = "G", ["Р"] = "H",
        ["О"] = "J", ["Л"] = "K", ["Д"] = "L", ["Ж"] = ":", ["Э"] = "\"",
        ["Я"] = "Z", ["Ч"] = "X", ["С"] = "C", ["М"] = "V", ["И"] = "B",
        ["Т"] = "N", ["Ь"] = "M", ["Б"] = "<", ["Ю"] = ">"
    }) {
        text = string.gsub(text, k, v)
    }

    return text
}

sampev.onSendChat = fn(message) {
    local possibleDot, command, arguments = string.match(message, "^(.)(%S*)(.*)")
    if possibleDot == "." && config.root.additions.swapLayout.use {
        local swappedCommand = swapLayout(command)
        if sampIsChatCommandDefined(swappedCommand) {
            sampProcessChatInput("/" .. ((arguments) ? swappedCommand .. arguments : output))
        } else {
            sampSendChat("/" .. ((arguments) ? swappedCommand .. arguments : output))
        }
        return false
    }
}
