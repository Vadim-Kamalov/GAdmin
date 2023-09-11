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

@import "Common"        => common
@import "imgui.Assets"  => imguiAssets

local animations = {}

/**
 * Draw animated and clickable text.
 *
 * @param label             string
 * @param text              string
 * @param font              ImFont|nil
 * @param areaToClickSize   ImVec2|nil
 * @param duration          number|nil
 * @param colors            table|nil
 * @return boolean, boolean (imgui.IsItemClicked(), imgui.IsItemHovered())
 */
method animations::clickableText(
    label,
    text,
    font = regular9,
    areaToClickSize = imgui.ImVec4(0, 0),
    duration = 0.2,
    colors = {
        def     = common::convertHex2ImVec4("5B5B5B"),
        hovered = common::convertHex2ImVec4("FFFFFF")
    }
) {
    
    if !UI_CLICKABLE_TEXT {
        global UI_CLICKABLE_TEXT = {}
    }

    if !UI_CLICKABLE_TEXT[label] {
        UI_CLICKABLE_TEXT[label] = {
            color   = colors.def,
            hovered = {
                cur     = false,
                old     = false,
                clock   = nil
            }
        }
    }

    local this, result = UI_CLICKABLE_TEXT[label], nil
    {
        if font { imgui.PushFont(font) }

        local pos = imgui.GetCursorPos()
        imgui.SetCursorPos(imgui.ImVec2(
            pos.x + math.max(0, areaToClickSize.x / 2 - imgui.CalcTextSize(text).x / 2),
            pos.y + math.max(0, areaToClickSize.y / 2 - imgui.CalcTextSize(text).y / 2)
        ))
        imgui.TextColored(this.color, text)

        if font { imgui.PopFont() }
    
        imgui.SetCursorPos(pos)
        result = imgui.InvisibleButton(label, areaToClickSize)

        this.hovered.cur = imgui.IsItemHovered()
        if this.hovered.old != this.hovered.cur {
            this.hovered.old    = this.hovered.cur
            this.hovered.clock  = os.clock()
        }
    }

    if this.hovered.clock {
        if os.clock() - this.hovered.clock <= duration {
            this.color = imguiAssets::bringVec4To(
                $,
                (this.hovered.cur) ? colors.hovered : colors.def,
                this.hovered.clock,
                duration
            )
        } else {
            this.color = (this.hovered.cur) ? colors.hovered : colors.def
        }
    }

    return result
}

return animations
