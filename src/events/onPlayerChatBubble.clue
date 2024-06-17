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

@import "Config" => config

sampev.onPlayerChatBubble = fn(playerId, color, distance, duration, message) {
    if config.root.windows.farChat.use {
        if color == -413892353 && string.sub(message, 1, 1) != '*' {
            return { playerId, color, distance, duration, message }
        }

        if local it = farChatMessages[#farChatMessages] {
            if os.clock() - it.clock <= config.root.windows.farChat.delay && u8(message) == it.message && playerId == it.id {
                return { playerId, color, distance, duration, message }
            }
        }

        table.insert(farChatMessages, {
            id          = playerId,
            nickname    = sampGetPlayerNickname(playerId),
            color       = (color == 0) ? -1 : color,
            distance    = distance,
            message     = u8(message),
            clock       = os.clock(),
            time        = os.date("*t")
        })
    }
}
