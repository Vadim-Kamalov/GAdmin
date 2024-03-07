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

@import "Config"         => config
@import "game.Spectator" => spectator
@import "game.User"      => user
@import "Assets"         => assets

sampev.onSendChat = fn(message) {
    local possibleDot, command, arguments = string.match(message, "^(%.+)(%S*)(.*)")
    if possibleDot == "." && config.root.additions.swapLayout.use {
        local swappedCommand = assets::swapLayout(command)
        if sampIsChatCommandDefined(swappedCommand) {
            sampProcessChatInput("/" .. swappedCommand .. arguments)
        } else {
            sampSendChat("/" .. u8(swappedCommand .. arguments))
        }
        return false
    }

    if config.root.additions.autoAACommand.use && user::getAloginStatus() && !spectator.status {
        sampSendChat("/aa " .. u8(message))
        return false
    }
}
