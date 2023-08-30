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

local imguiAssets = {}

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

return imguiAssets
