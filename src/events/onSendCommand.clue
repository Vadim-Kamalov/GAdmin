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

@import "CommandRequester"  => commandRequester
@import "Config"            => config
@import "game.User"         => user

method sampev.onSendCommand(command) {
    local command = u8($)

    commandRequester::setupUserCommandWatcher(command)

    if config.root.additions.shortCommands.use {
        for key, value of config.root.additions.shortCommands.commands {
            if string.lower(string.match(command, "^/(%S+)%s*") || "") == key {
                sampSendChat(string.format("/" .. value, select(1, string.match(command, "^/%S+(.*)"))))
                return false
            }
        }
    }

    if config.root.windows.vehicleSelectionPanel.use && string.find(string.lower(command), "^/veh%s*$")
@ifndef __GADMIN_DEBUG__
{
       && user::getAloginStatus() && user::getAdminLvl() >= 4
}
    {
        vehicleSelectionPanel::open()
        return false
    }
}
