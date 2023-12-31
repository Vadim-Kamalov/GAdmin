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

local text = {}

/**
 * Render stroked text using ImDrawList.
 *
 * @param drawList      ImDrawList
 * @param text          string
 * @param pos           ImVec2
 * @param color         ColorU32Vec4
 * @param font          ImFont
 * @param textSize      number
 * @param strokeWidth   number
 *
 * @return void
 */
method text::addStroke(drawList, text, color, pos, font, textSize, strokeWidth = 1) {
    local blackColor = imgui.GetColorU32Vec4(imgui.ImVec4(0, 0, 0, 1))
    if font { imgui.PushFont(font) }
    if strokeWidth > 0 {
        drawList::AddTextFontPtr(font, textSize, imgui.ImVec2(pos.x + strokeWidth, pos.y + strokeWidth), blackColor, text)
        drawList::AddTextFontPtr(font, textSize, imgui.ImVec2(pos.x - strokeWidth, pos.y - strokeWidth), blackColor, text)
        drawList::AddTextFontPtr(font, textSize, imgui.ImVec2(pos.x + strokeWidth, pos.y - strokeWidth), blackColor, text)
        drawList::AddTextFontPtr(font, textSize, imgui.ImVec2(pos.x - strokeWidth, pos.y + strokeWidth), blackColor, text)
    }
    drawList::AddTextFontPtr(font, textSize, pos, color, text)
    if font { imgui.PopFont(font) }
}

/**
 * Render colored text using ImDrawList. Text must be next format:
 *  {HEX}{SOME_TEXT}; for example: {FFFFFF}{Hello,}{FF0000}{ world!};
 * All symbols that not in `{}` characters are ignored.
 *
 * @param drawList      ImDrawList
 * @param text          string
 * @param pos           ImVec2
 * @param font          ImFont
 * @param textSize      number
 * @param strokeWidth   number
 *
 * @return void
 */
method text::addColored(drawList, text, pos, font = nil, textSize = 14, strokeWidth = 1) {
    local changeablePos     = imgui.ImVec2(pos.x, pos.y)
    local textColoredList   = (fn {
        local output = {}
        for color, coloredText with string.gmatch(text, "{(%x%x%x%x%x%x)}{(.-)}") {
            table.insert(output, { text = coloredText, hex = color, size = imgui.CalcTextSize(coloredText) })
        }
        return output
    })()

    if font { imgui.PushFont(font) }
    for _, data in textColoredList {
        local r, g, b, _    = assets::explodeARGB(tonumber(data.hex .. "FF", 16))
        local color         = imgui.GetColorU32Vec4(imgui.ImVec4(r / 255, g / 255, b / 255, 1 /* Alpha */))
        self::addStroke(drawList, data.text, color, changeablePos, font, textSize, strokeWidth)
        
        if data.text == "\n" {
            changeablePos.y += data.size.y + textSize / 2.5
            changeablePos.x = pos.x
        } else {
            changeablePos.x += data.size.x + textSize / 2.5
        }
    }
    if font { imgui.PopFont(font) }
}

return text
