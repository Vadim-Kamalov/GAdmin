/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023-2025 The Contributors.
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

local chatInputBox = {}

method chatInputBox::getPosition() {
    local DXUTEditBox   = getStructElement(sampGetInputInfoPtr(), 0x8, 4)
    local posX, posY    = getStructElement(DXUTEditBox, 0x8, 4), getStructElement(DXUTEditBox, 0xC, 4) + 50
    return posX, posY
}

return chatInputBox
