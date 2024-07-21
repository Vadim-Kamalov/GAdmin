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

@import "game.Spectator" => spectator

method sampev.onCreate3DText(
    id,
    color,
    position,
    distance,
    testLOS,
    attachedPlayerId,
    attachedVehicleId,
    text
) {
    local attachedPlayerId  = (attachedPlayerId == 65535) ? nil : attachedPlayerId
    local text              = u8(text)
    if attachedPlayerId {
        if attachedPlayerId == tonumber(spectator.id) {
            spectator::setInformation({
                stage = (string.find(text, "%(%( Данный персонаж ранен %d+ раз%(%-а%) %- /dm %d+ %)%)")) ? "1##" .. tostring(id) :
                        (string.find(text, "%(%( ДАННЫЙ ПЕРСОНАЖ .+ %)%)") ? "2##" .. tostring(id) : "0##" .. tostring(id))
            })
        }
    }
}
