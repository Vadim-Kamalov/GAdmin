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

@ifdef __GADMIN_DEBUG__
{

@import "AutoUpdate"        => autoUpdate
@import "Assets"            => assets
@import "game.GReport"      => greport
@import "CommandRequester"  => commandRequester

local commands = {}

/**
 * Initialize all console commands.
 * @return void
 */
method commands::init() {
    for command, callback of self {
        if command != "init" {
            sampfuncsRegisterConsoleCommand("debug." .. command, callback)
        }
    }
}

method commands.runAutoUpdate() {
    autoUpdate.windowState = true
    autoUpdate.imgui       = {
        body    = "<header>Hello, world!</header>",
        title   = "DebugCommands.runAutoUpdate",
        version = "debug",
        buttons = {
            first   = "First Button",
            second  = "Second Button",
            third   = "Third Button"
        }
    }
}

method commands.fillFarChatMessages(times) {
    math.randomseed(os.time())
    for index = 1, (tonumber(times) || 100) {
        table.insert(farChatMessages, {
            id          = math.random($SERVER_MAX_PLAYERS),
            nickname    = assets.randomICNicknames[math.random(#assets.randomICNicknames)],
            color       = -1,
            distance    = 0,
            message     = assets.randomStrings[math.random(#assets.randomStrings)],
            clock       = os.clock(),
            time        = os.date("*t")
        })
    }
}

method commands.switchGreportWindow() {
    greport.window::switch()
}

method commands.runCommandRequesterFrame(id) {
    commandRequester.states.frame             = true
    commandRequester.current.id.from          = tonumber(id)
    commandRequester.current.clock            = os.clock()
    commandRequester.current.command.splitted = { name = "debug", args = "debug" }
}

return commands

} // @ifdef __GADMIN_DEBUG__
