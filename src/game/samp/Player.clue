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
 * SDPX-License-Identifier: GPL-3.0-only
 */

local player = {}

method player::getIdByNickname(nickname) {
    local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if nickname == sampGetPlayerNickname(myid) { return myid }
    for i = 0, $SERVER_MAX_PLAYERS {
        if sampIsPlayerConnected(i) && sampGetPlayerNickname(i) == nickname {
            return i
        }
    }
    return nil
}

return player
