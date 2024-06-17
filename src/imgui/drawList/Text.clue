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
 * SPDX-License-Identifier: GPL-3.0-only
 */

@import "Assets" => assets

local text = {}

/**
 * Render stroked text using ImDrawList.
 *
 * @param drawList      ImDrawList
 * @param text          string
 * @param pos           ImVec2
 * @param color         number (u32)
 * @param font          ImFont
 * @param textSize      number
 * @param strokeWidth   number
 *
 * @return void
 */
method text::addStroke(drawList, text, color, pos, font, textSize, strokeWidth = 1) {
    local blackColor = imgui.GetColorU32Vec4(imgui.ImVec4(0, 0, 0, 1))
    if strokeWidth > 0 {
        drawList::AddTextFontPtr(font, textSize, imgui.ImVec2(pos.x + strokeWidth, pos.y + strokeWidth), blackColor, text)
        drawList::AddTextFontPtr(font, textSize, imgui.ImVec2(pos.x - strokeWidth, pos.y - strokeWidth), blackColor, text)
        drawList::AddTextFontPtr(font, textSize, imgui.ImVec2(pos.x + strokeWidth, pos.y - strokeWidth), blackColor, text)
        drawList::AddTextFontPtr(font, textSize, imgui.ImVec2(pos.x - strokeWidth, pos.y + strokeWidth), blackColor, text)
    }
    drawList::AddTextFontPtr(font, textSize, pos, color, text)
}

/**
 * Draw text that passed in `objects` array. `objects` argument example: 
 *
 * ```clue
 * {
 *     { /// Text render configuration. These tables are unlimited in the current array.
 *         text: string,       /// The text. Don't use `\n` inside of this string!
 *         size: number,       /// The text font size.
 *         stroke: number = 1, /// Size of the text stroke.
 *         color: ImVec4  = imgui.GetStyle().Colors[imgui.Col.Text],
 *         font: ImFont   = _G.bold
 *     },
 *
 *     /// You can also set position of the next rendered item.
 *     { x: number = 0, y: number = 0 },
 *
 *     /// Or just add a new line.
 *     "NewLine",
 *
 *     /// ...
 * }
 * ```
 *
 * @param drawList ImDrawList
 * @param position ImVec2
 * @param objects table<number, table<string, string|number|ImVec4|ImFont>|"NewLine">
 * @return void
 */
method text::renderTextObjects(drawList, position, objects) {
    local basePosition = imgui.ImVec2(position.x, position.y)
    local maxTextSize  = 0

    for _, object in objects {
        if type(object) == "string" && object == "NewLine" {
            basePosition.x, basePosition.y = position.x, basePosition.y + maxTextSize + 2
            maxTextSize = 0
        } elseif object.x || object.y {
            basePosition.x, basePosition.y = object.x || 0, object.y || 0
        } else {
            object.font ??= bold

            self::addStroke(
                drawList,
                object.text,
                imgui.ColorConvertFloat4ToU32(object.color || imgui.GetStyle().Colors[imgui.Col.Text]),
                basePosition,
                object.font,
                object.size,
                object.stroke || 1
            )

            basePosition.x += object.font::CalcTextSizeA(object.size, math.huge, 0.0, object.text).x

            if object.size > maxTextSize {
                maxTextSize = object.size
            }
        }
    }
}

return text
