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
@import "imgui.Style"   => style

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
        if string.find(tostring(style), "^ImVec2") || type(style) == "number" {
            imgui.GetStyle()[property] = style
        } else {
            imgui.GetStyle().Colors[imgui.Col[property]] = (type(style) == "string") ? 
                common::convertHex2ImVec4(style) : style
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
    for property, oldValue of self {
        if local defaultValue = style.def[property] {
            if string.find(tostring(oldValue), "^ImVec2") || type(oldValue) == "number" {
                imgui.GetStyle()[property] = defaultValue
            } else {
                imgui.GetStyle().Colors[imgui.Col[property]] = defaultValue
            }
        }
    }
}

/**
 * Update properties in `self` with `style` parameter.
 * 
 * @param style table
 * @return void
 */
method StyleChanger::update(style) {
    for property, value of style {
        self[property] = value
    }
}

/**
 * Get safe table for writing it in config. Converts all ImGui vectors
 * to packed tables, strings to vectors, numbers are unchanged.
 *
 * @return table
 */
method StyleChanger::getConfigSafeTable() {
    local result = {}
    for property, value of self {
        if string.find(tostring(value), "^ImVec2") {
            result[property] = { value.x, value.y }
        } elseif type(value) == "number" {
            result[property] = value
        } else {
            local value = (type($) == "string") ? common::convertHex2ImVec4(value) : $
            result[property] = { value.x, value.y, value.z, value.w }
        }
    }
    return result
}

return StyleChanger
