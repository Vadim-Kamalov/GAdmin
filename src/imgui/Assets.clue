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

@import "Icons"         => icons
@import "Notifications" => notify
@import "Common"        => common

static __imguiAssets__ = {
    cursor = true
}

/**
 * @return boolean Whether the ImGui cursor is active (Cursor Status).
 */
method __imguiAssets__::getCursorStatus() { return self.cursor }

/**
 * Change the global cursor display ONLY for ImGui windows.
 *
 * @param status boolean Cursor status (default = false).
 * @return void
 */
method __imguiAssets__::setCursorStatus(status = false) { self.cursor = status  }

/**
 * Globally change the state of the ImGui cursor.
 * @return void
 */
method __imguiAssets__::switchCursorStatus() { self.cursor = !$ }

/**
 * Drawing imgui text with a specific font, optionally with a position.
 *
 * @param text string
 * @param font ImFont
 * @param pos ImVec2
 * @return void
 */
method __imguiAssets__::textWithFont(text, font, pos, color = imgui.GetStyle().Colors[imgui.Col.Text]) {
    imgui.PushFont(font)
        if pos { imgui.SetCursorPos(pos) }
        imgui.TextColored(color, text)
    imgui.PopFont()
}

/**
 * Bring float from first to second float.
 *
 * @param from number
 * @param to number
 * @param startTime number os.clock()
 * @param duration number
 * @return number, boolean 
 */
method __imguiAssets__::bringFloatTo(from, to, startTime, duration) {
    local timer = os.clock() - startTime
    if timer >= 0.00 && timer <= duration {
        local count = timer / (duration / 100)
        return from + (count * (to - from) / 100), true
    }
    return ((timer > duration) ? to : from), false
}

/**
 * Bring ImVec2 from first to second ImVec2.
 *
 * @param from ImVec2
 * @param second ImVec2
 * @param startTime number os.clock()
 * @param duration number
 * @return number, boolean
 */
method __imguiAssets__::bringVec2To(from, to, startTime, duration) {
    local timer = os.clock() - startTime
    if timer >= 0.00 && timer <= duration {
        local count = timer / (duration / 100)
        return imgui.ImVec2(
            from.x + (count * (to.x - from.x) / 100),
            from.y + (count * (to.y - from.y) / 100)
        ), true
    }
    return ((timer > duration) ? to : from), false
}

/**
 * Bring ImVec4 from first to second ImVec4
 *
 * @param from ImVec4
 * @param to ImVec4
 * @param startTime number os.clock()
 * @param duration number
 * @return number, boolean
 */
method __imguiAssets__::bringVec4To(from, to, startTime, duration) {
    local timer = os.clock() - startTime
    if timer >= 0.00 && timer <= duration {
        local count = timer / (duration / 100)
        return imgui.ImVec4(
            from.x + (count * (to.x - from.x) / 100),
            from.y + (count * (to.y - from.y) / 100),
            from.z + (count * (to.z - from.z) / 100),
            from.w + (count * (to.w - from.w) / 100)
        ), true
    }
    return ((timer > duration) ? to : from), false
}

/**
 * Add stroked ImGui text.
 *
 * @param text string
 * @param strokeWidth number|nil
 * @param color ImVec4|nil
 * @vararg any
 * @return boolean, boolean (imgui.IsItemClicked() and imgui.IsItemHovered())
 */
method __imguiAssets__::addStrokedText(text, strokeWidth = 0, color = imgui.ImVec4(1, 1, 1, 1), ...) {
    local text  = string.format($, ...)
    local pos   = imgui.GetCursorPos()

    imgui.BeginGroup()
        for i = 1, strokeWidth {
            imgui.SetCursorPos(imgui.ImVec2(pos.x + i, pos.y))
            imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text)
            imgui.SetCursorPos(imgui.ImVec2(pos.x - i, pos.y))
            imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text)
            imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y + i))
            imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text)
            imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y - i))
            imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text)
        }

        imgui.SetCursorPos(pos)
        imgui.TextColored(color, text)
    imgui.EndGroup()

    return imgui.IsItemClicked(), imgui.IsItemHovered()
}

/**
 * Convert hex to C-float number type (size == 3).
 * @param hex string
 * @return cdata
 */
method __imguiAssets__::convertHex2Float3(hex) {
    local vector = common::convertHex2ImVec4(hex)
    local float3 = ffi.new("float[3]")

    float3[0] = vector.x
    float3[1] = vector.y
    float3[2] = vector.z

    return float3
}

/**
 * Set previous ImGui item able to copy.
 *
 * @param text string
 * @param notifyTitle string|nil
 * @param notifyDescription string|nil
 * @param notification table|nil
 * @return void
 */
method __imguiAssets__::setPreviousItemAbleToCopy(
    text,
    notifyTitle = "Текст скопирован",
    notifyDescription = "Следующий текст успешно скопирован: " .. text,
    notification
) {
    notification = notification || {
        icon    = icons.ICON_KEYBOARD
        title   = notifyTitle
        text    = notifyDescription
    }

    if imgui.IsItemHovered() {
        imgui.GetWindowDrawList()::AddLine(
            imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y),
            imgui.GetItemRectMax(),
            -1,
            2
        )
    } if imgui.IsItemClicked() {
        setClipboardText(tostring(text))
        notify::send(notification)
    }
}

return __imguiAssets__
