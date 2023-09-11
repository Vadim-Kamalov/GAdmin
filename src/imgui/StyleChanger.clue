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

@import "Common" => common

local StyleChanger = {}; StyleChanger.__index = StyleChanger

/**
 * Register StyleChanger class. `style` acts as table, an example:
 *
 * ```clue
 * StyleChanger::new({
 *     Property = { new = ImVec2|ImVec4|Number, old = ImVec2|ImVec4|Number }
 * })
 * ```
 *
 * @class StyleChanger
 * @param style table
 * @return StyleChanger
 */
method StyleChanger::new(style) {
    setmetatable(style, self)
    self.__index = self
    return style
}

/**
 * Applies the style that was previously passed through the class constructor.
 *
 * @see StyleChanger::new
 * @return void
 */
method StyleChanger::apply() {
    for property, style of self {
        if string.find(tostring(style.new), "^ImVec2") || type(style.new) == "number" {
            imgui.GetStyle()[property] = style.new
        } else {
            imgui.GetStyle().Colors[imgui.Col[property]] = (type(style.new) == "string") ? 
                common::convertHex2ImVec4(style.new) : style.new
        }
    }
}

/**
 * Resets the style that was applied via StyleChanger::apply. 
 *
 * @see StyleChanger::new
 * @see StyleChanger::apply
 * @return void
 */
method StyleChanger::reset() {
    for property, style of self {
        if string.find(tostring(style.old), "^ImVec2") || type(style.old) == "number" {
            imgui.GetStyle()[property] = style.old
        } else {
            imgui.GetStyle().Colors[imgui.Col[property]] = (type(style.old) == "string") ? 
                common::convertHex2ImVec4(style.old) : style.old
        }
    }
}

return StyleChanger