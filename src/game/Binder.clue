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

@import "game.binder.Variables" => variables
@import "imgui.HotKey"          => HotKey
@import "Config"                => config

local binder = {}

/**
 * Preprocesses variables that defined in `game.binder.Variables` and sends 
 * input to SA:MP chat(`input` can be multilined). Variable format:
 * 
 *   ${{ VARIABLE_NAME, <replace> }}, where:
 *
 * `VARIABLE_NAME`   - name of variable;
 * `<replace>`       - optional argument; string that will be replaced if got `nil` from `VARIABLE_NAME`. (default = "N/A")
 *
 *
 * Extra variable to get arguments that passed in `arguments = {}` argument: `${{ GET_ARGUMENT, <argument index> }}`.
 *  `<argument index>` isn't optional and value always must be number and above zero.
 *
 * @see game.binder.Variables
 *
 * @param input                 string
 * @param arguments             table|nil   (default = {})
 * @param delayBetweenMessages  number|nil  (default = $COMMAND_DELAY)
 * @return void
 */
method binder::sendString(input, arguments = {}, delayBetweenMessages = $COMMAND_DELAY) {
    input = string.gsub($, "%${{(.-)}}", fn(params) {
        if local variable, params = string.match(params, "^%s*([A-Z_]+)(.*)") {
            local parameter = nil

            if #params > 0 && string.sub(params, 1, 1) == ',' {
                parameter = string.match(params, "^,%s*(.*)")
                if local start, _ = string.find(parameter, "%s*$") {
                    parameter = (start != 1) ? string.sub($, 1, start - 1) : ""
                }
            }

            if variable == "GET_ARGUMENT" && tonumber(parameter) {
                if local argument = arguments[tonumber(parameter)] {
                    return argument
                }
            } else {
                if local callback = variables[variable] {
                    if local result = callback() {
                        return result
                    } else {
                        return parameter || "N/A"
                    }
                }
            }
        }

        return ""
    })

    lua_thread.create(fn {
        for line with string.gmatch(input, "[^\n]+") {
            if sampIsChatCommandDefined(string.match(line, "^/(.+)[ $]") || "-1") {
                sampProcessChatInput(line)
            } else {
                sampSendChat(line)
            }
            
            wait(delayBetweenMessages)
        }
    })
}

/**
 * Add new bind.
 *
 * @param title                 string
 * @param value                 string
 * @param delayBetweenMessages  number|nil
 * @param commandName           string|nil
 * @return void
 */
method binder::newBind(title, value, delayBetweenMessages, commandName) {
    table.insert(config.root.binds, {
        title       = title,
        value       = value,
        delay       = delayBetweenMessages,
        keys        = {},
        commandName = commandName
    })

    if commandName {
        sampRegisterChatCommand(commandName, fn(args = "") {
            local arguments = {}

            for argument with string.gmatch(args, "[^%s]+") {
                table.insert(arguments, argument)
            }

            self::sendString(value, arguments, delayBetweenMessages)
        })
    }

    HotKey::new("binderIndex" .. #config.root.binds, {})::registerCallback(fn {
        self::sendString(value, nil, delayBetweenMessages)
    })
}

/**
 * Initialize all binds: register commands, keyBinds.
 * @return void
 */
method binder::initializeBinds() {
    for index, bind in config.root.binds {
        if bind.commandName {
            sampRegisterChatCommand(bind.commandName, fn(args = "") {
                local arguments = {}

                for argument with string.gmatch(args, "[^%s]+") {
                    table.insert(arguments, argument)
                }

                self::sendString(bind.value, arguments, bind.delay)
            })
        }

        HotKey::new("binderIndex" .. index, bind.keys)::registerCallback(fn {
            self::sendString(bind.value, nil, bind.delay)
        })
    }
}

return binder
