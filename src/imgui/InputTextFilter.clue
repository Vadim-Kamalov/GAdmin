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

@import "Common" => common

/**
 * This class is needed to implement text filter in ImGui. Yes, it's already implemented
 * in `imgui.ImGuiTextFilter()`, but this works bad with case sensivity for russian
 * symbols. Our class is using standart LuaJIT functions like `string.find`, and
 * rendered via `imgui.InputTextWithHint` (there isn't such function in default
 * imgui `InputTextFilter` class).
 *
 * @class InputTextFilter
 * @field public buffer cdata
 */
local InputTextFilter = {}; InputTextFilter.__index = InputTextFilter

/**
 * Create new `InputTextFilter` class instance.
 * 
 * @return InputTextFilter
 */
method InputTextFilter::new() {
    setmetatable({}, self)

    self.__index    = self
    self.buffer     = imgui.new.char[256]()

    return self
}

/**
 * Helper for `SetNextItemWidth` and `InputTextWithHint`.
 *
 * @see InputTextFilter
 *
 * @param label string
 * @param hint string|nil
 * @param with number|nil
 * @return boolean
 */
method InputTextFilter::draw(label, hint = "Поиск", width = 0.0, font = regular10) {
    if width != 0.0 {
        imgui.SetNextItemWidth(width)
    }

    imgui.PushFont(font)
        local result = imgui.InputTextWithHint(label, hint, self.buffer, ffi.sizeof(self.buffer))
    imgui.PopFont()

    return result
}

/**
 * Find `filter` in `InputTextFilter.buffer` via `string.find` with `plain` enabled.
 *
 * @param filter string
 * @return boolean
 */
method InputTextFilter::passFilter(filter) {
    local filter = common::toLowerCase($)
    local buffer = common::toLowerCase(ffi.string(self.buffer))
    local result = string.find(filter, buffer, 1, true)

    return (buffer == "") ? true : result
}

/**
 * Set text to `InputTextFilter.buffer`.
 *
 * @see InputTextFilter
 * @see InputTextFilter.buffer
 *
 * @param text string
 * @return void
 */
method InputTextFilter::setBufferText(text) {
    imgui.StrCopy(self.buffer, text)
}

/**
 * Clear `InputTextFilter.buffer`.
 *
 * @see InputTextFilter::setBufferText
 * @return void
 */
method InputTextFilter::clear() {
    self::setBufferText("")
}

return InputTextFilter
