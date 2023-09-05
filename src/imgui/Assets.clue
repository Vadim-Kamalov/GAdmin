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

local imguiAssets = {}; imguiAssets.__index = imguiAssets

imguiAssets.cursor = true

/**
 * @return boolean Whether the ImGui cursor is active (Cursor Status).
 */
method imguiAssets::getCursorStatus() { return self.cursor }

/**
 * Change the global cursor display ONLY for ImGui windows.
 *
 * @param status boolean Cursor status (default = false).
 * @return void
 */
method imguiAssets::setCursorStatus(status = false) { self.cursor = status  }

/**
 * Globally change the state of the ImGui cursor.
 * @return void
 */
method imguiAssets::switchCursorStatus() { self.cursor = !$ }

/**
 * Drawing imgui text with a specific font, optionally with a position.
 *
 * @param text string
 * @param font ImFont
 * @param pos ImVec2
 * @return void
 */
method imguiAssets::textWithFont(text, font, pos) {
    imgui.PushFont(font)
        if (pos) { imgui.SetCursorPos(pos) }
        imgui.Text(text)
    imgui.PopFont()
}

method imguiAssets::bringFloatTo(from, to, startTime, duration) {
    local timer = os.clock() - startTime
    if timer >= 0.00 && timer <= duration {
        local count = timer / (duration / 100)
        return from + (count * (to - from) / 100), true
    }
    return (timer > duration) ? to : from, false
}

return imguiAssets
