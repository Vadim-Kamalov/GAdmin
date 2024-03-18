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

@import "game.User" => user
@import "Config"    => config

local sendedCommand = false

sampev.onTogglePlayerControllable = fn(controllable) {
    if scriptLoadedWithGame && controllable &&
        !sendedCommand && config.root.additions.autoAdminLogin.use
    {
        sampSendChat("/alogin")

        //! I don’t know why, but after sending a command to the chat
        //! the server does not count that the player is unfrozen.
        
        freezeCharPosition(PLAYER_PED, true)
		freezeCharPosition(PLAYER_PED, false)
		setPlayerControl(PLAYER_HANDLE, true)
		restoreCameraJumpcut()
		clearCharTasksImmediately(PLAYER_PED)

        sendedCommand = true;
    }
}
