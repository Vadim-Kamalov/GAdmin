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

local shadow = {}

/**
 * Render shadow using compressed.shadowPng effect.
 *
 * @param drawList ImDrawList
 * @param from ImVec2
 * @param to ImVec2
 * @param size number
 * @param opacity number (0 .. 255)
 * @param rate number
 * @return void
 */
method shadow::apply(drawList, from, to, size, opacity, rate) {
    local color = (opacity << 24) | 0xFFFFFF
    local uv0   = 0.0
    local uv1   = 0.333333
    local uv2   = 0.666666
    local uv3   = 1.0
    local p     = from
    local s     = to
    local m     = imgui.ImVec2(p.x + s.x, p.y + s.y)
    
    drawList::PushClipRectFullScreen()
    for i = 1, rate {
        drawList::AddImage(shadowPng, imgui.ImVec2(p.x - size, p.y - size), imgui.ImVec2(p.x, p.y), imgui.ImVec2(uv0, uv0), imgui.ImVec2(uv1, uv1), color)
        drawList::AddImage(shadowPng, imgui.ImVec2(p.x, p.y - size), imgui.ImVec2(m.x, p.y), imgui.ImVec2(uv1, uv0), imgui.ImVec2(uv2, uv1), color)
        drawList::AddImage(shadowPng, imgui.ImVec2(m.x, p.y - size), imgui.ImVec2(m.x + size, p.y), imgui.ImVec2(uv2, uv0), imgui.ImVec2(uv3, uv1), color)
        drawList::AddImage(shadowPng, imgui.ImVec2(p.x - size, p.y), imgui.ImVec2(p.x, m.y), imgui.ImVec2(uv0, uv1), imgui.ImVec2(uv1, uv2), color)
        drawList::AddImage(shadowPng, imgui.ImVec2(m.x, p.y), imgui.ImVec2(m.x + size, m.y), imgui.ImVec2(uv2, uv1), imgui.ImVec2(uv3, uv2), color)
        drawList::AddImage(shadowPng, imgui.ImVec2(p.x - size, m.y), imgui.ImVec2(p.x, m.y + size), imgui.ImVec2(uv0, uv2), imgui.ImVec2(uv1, uv3), color)
        drawList::AddImage(shadowPng, imgui.ImVec2(p.x, m.y), imgui.ImVec2(m.x, m.y + size), imgui.ImVec2(uv1, uv2), imgui.ImVec2(uv2, uv3), color)
        drawList::AddImage(shadowPng, imgui.ImVec2(m.x, m.y), imgui.ImVec2(m.x + size, m.y + size), imgui.ImVec2(uv2, uv2), imgui.ImVec2(uv3, uv3), color)
    }
    drawList::PopClipRect()
}

return shadow
