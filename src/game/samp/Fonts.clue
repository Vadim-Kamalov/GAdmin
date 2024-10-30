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

ffi.cdef("
    typedef struct {
        long x;
        long y;
    } point_t;
")

local fonts = {
    pointer = nil,
    measureTextCast = ffi.cast("point_t*(__thiscall*)(void*, void*, const char*, unsigned long)", $SAMP_BASE + 0x66B20)
}

/**
 * @return boolean Wheather `fonts.pointer` is not null.
 */
method fonts::isAvailable() {
    if !self.pointer {
        if local pointer = ffi.cast("void**", $SAMP_BASE + 0x21A0FC)[0] {
            self.pointer = pointer
            return true
        }

        return false
    }

    return true
}

/**
 * Get size of the `text` on the screen.
 *
 * @param text string
 * @return number, number
 */
method fonts::measureText(text) {
    local point  = ffi.new("point_t")
    local result = self.measureTextCast(self.pointer, point, text, 0)
    return result[0].x, result[0].y
}

return fonts
