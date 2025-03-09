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

local chat = { scrollbar = {} }

/**
 * Get the top-left position of the chat context.
 * @return number, number
 */
method chat::getPosition() {
    return memory.getint8($SAMP_BASE + 0x63DB1), memory.getint8($SAMP_BASE + 0x63DA0)
}

/**
 * @return boolean Wheather timestamp is enabled.
 */
method chat::isTimestampEnabled() {
    return memory.getint8(sampGetChatInfoPtr() + 0xC) == 1
}

/**
 * Get width of the timestamp text.
 * Note: actual position to the chat entry is `chat::getTimestampWidth() + 5`.
 *
 * @return number
 */
method chat::getTimestampWidth() {
    return memory.getint32(sampGetChatInfoPtr() + 0x63E6)
}

/**
 * Get height of a string in the chat.
 * @return number
 */
method chat::getStringHeight() {
    return memory.getint8(sampGetChatInfoPtr() + 0x63E2)
}

/**
 * Get current position of the scrollbar.
 * @return number
 */
method chat.scrollbar::getCurrentPosition() {
    return memory.getint8(memory.getuint32(sampGetChatInfoPtr() + 0x11E, true) + 0x8E, true)
}

/**
 * Get pagesize of the scrollbar.
 * @return number
 */
method chat.scrollbar::getPagesize() {
    return memory.getint8(memory.getuint32(sampGetChatInfoPtr() + 0x11E, true) + 0x92, true)
}

return chat
