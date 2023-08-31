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

local spectator = {}; spectator.__index = spectator

spectator.isInSpectator = false
spectator.id            = -1
spectator.nickname      = ""

/**
 * @return boolean Whether the player (PLAYER_PED) is in spectator.
 */
method spectator::getStatus() { return self.status }

/**
 * Switch the spectator status ONLY in the table. To set player tracking, use spectator::setTo.
 * 
 * @see spectator::setTo
 *
 * @param _status boolean Spectator status (default = `false`).
 * @return void
 */
method spectator::setStatus(_status = false) { self.status = _status }

/**
 * @return string The player nickname who was last (or currently) spectated by the user.
 */
method spectator::getNickname() { return self.nickname }

/**
 * @return string The player id who was last (or currently) spectated by the user.
 */
method spectator::getId() { return self.id }

/**
 * Go in to spectator to a specific player.
 *
 * @param playerId number   The player id that user should spectate to.
 * @param useDelay boolean  Use delay after sending message. By default it's false, delay taken from $COMMAND_DELAY const variable.
 * @return void
 */
method spectator::setTo(playerId, useDelay = false) {
    @ifdef __GADMIN_DEBUG__ {
        $debugInformation!("spectator::setTo", "called with playerId: " .. tostring(player) .. ". useDelay: " .. tostring(useDelay))
    }
    
    self::setStatus(true)
    self.id        = playerId
    self.nickname  = sampGetPlayerNickname(playerId)

    if (useDelay) { wait($COMMAND_DELAY) }
    sampSendChat("/sp " .. tostring(playerId))
}

/**
 * Get out of spectating a player. spectator.id and spectator.nickname will not changed.
 * 
 * @param useDefault boolean Use delay after sending message. By default it's false, delay taken from $COMMAND_DELAY const variable.
 * @return void
 */
method spectator::exit(useDelay = false) {
    @ifdef __GADMIN_DEBUG__ { $debugInformation!("spectator::exit", "called with useDelay:" .. tostring(useDelay)) }

    self::setStatus()
    
    if (useDelay) { wait($COMMAND_DELAY) }
    sampSendChat("/unsp")
}

return spectator
