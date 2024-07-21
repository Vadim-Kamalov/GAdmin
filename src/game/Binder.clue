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

@import "game.binder.Variables" => variables
@import "imgui.HotKey"          => HotKey
@import "imgui.Assets"          => imguiAssets
@import "imgui.Animations"      => animations
@import "Config"                => config

local binder = {}

/**
 * Preprocess variables that defined in `game.binger.Variables`.
 *
 * @see binder::sendString
 * @param input string
 * @param arguments table|nil
 * @return string
 */
method binder::preprocess(input, arguments = {}) {
    return string.gsub(input, "%${{(.-)}}", fn (params) {
        if local variable, params = string.match(params, "^%s*([A-Z_]+)(.*)") {
            local parameter = nil

            if #params > 0 && string.sub(params, 1, 1) == ',' {
                parameter = string.match(params, "^,%s*(.*)")
                if local start = string.find(parameter, "%s*$") {
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
}

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
 * @param command               string Need this parameter to avoid unhandled exception of `0C8F` opcode. 
 * @param input                 string
 * @param arguments             table|nil   (default = {})
 * @param delayBetweenMessages  number|nil  (default = $COMMAND_DELAY)
 * @return void
 */
method binder::sendString(command, input, arguments = {}, delayBetweenMessages = $COMMAND_DELAY) {
    input = self::preprocess(input, arguments)

    lua_thread.create(fn {
        for line with string.gmatch(input, "[^\n]+") {
            if string.find(line, "^%^") {
                lua_thread.create(fn {
                    wait(100)
                    sampSetChatInputEnabled(true)
                    sampSetChatInputText(string.sub(line, 2))
                })
            } else {
                local chatCommand = string.match(line, "^/(.+)[ $]")

                if chatCommand && (chatCommand != command && sampIsChatCommandDefined(chatCommand)) {
                    sampProcessChatInput(line)
                } else {
                    sampSendChat(line)
                }
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

            self::sendString(commandName, value, arguments, delayBetweenMessages)
        })
    }

    HotKey::new("binderIndex" .. #config.root.binds, {})::registerCallback(fn {
        self::sendString(commandName, value, nil, delayBetweenMessages)
    })
}

method binder::getPopupRenderer(buffer, popup, onInsertVariableCallback) {
    if !UI_BINDER_INPUT {
        global UI_BINDER_INPUT = imgui.new.char[256]()
    }

    local input = UI_BINDER_INPUT

    return fn {
        local fn insertVariable(variableName) {
            local value = string.format(
                "%s${{ %s%s }}",
                ffi.string(buffer),
                variableName,
                (#ffi.string(input) > 0) ? ", " .. ffi.string(input) : "" 
            )

            onInsertVariableCallback?(value)

            imgui.StrCopy(buffer, value)
            imgui.StrCopy(input, "")
            imgui.CloseCurrentPopup()
        }

        imgui.SetCursorPos(imgui.ImVec2(5, 5))
        imgui.BeginGroup()
            imguiAssets::textWithFont("Переменные биндера", bold14)
            
            imgui.PushFont(regular12)
                imgui.SetNextItemWidth(math.max(260, imgui.GetWindowWidth() - 10))
                imgui.InputTextWithHint("##binder::getPopupRenderer.input", "Параметр", input, ffi.sizeof(input))
            imgui.PopFont()
                
            imgui.BeginChild("binder::getPopupRenderer.list", imgui.ImVec2(imgui.GetWindowWidth() - 10, 300), true)
                imgui.SetCursorPos(imgui.ImVec2(5, 5))
                imgui.BeginGroup()
                    local width = math.max(240, imgui.GetWindowWidth() - 10) 
                        imgui.PushFont(bold10)
                            if animations::button("GET_ARGUMENT##binder::getPopupRenderer.variable", imgui.ImVec2(width, 25)) {
                                insertVariable("GET_ARGUMENT")
                            }
                        imgui.PopFont()
    
                        imgui.PushFont(regular12)
                            animations::hint("Получить значение аргумента по индексу, но только если бинд выполнен через команду\n"
                                .. "Обязательный параметр: индекс аргумента (начиная с 1)")
                        imgui.PopFont()

                        for _, id in variables.order {
                            imgui.PushFont(bold10)
                                if animations::button(id .. "##binder::getPopupRenderer.variable", imgui.ImVec2(width, 25)) {
                                    insertVariable(id)
                                }
                            imgui.PopFont()
                            imgui.PushFont(regular12)
                                animations::hint(variables.description[id]
                                    .. "\nНеобязательный параметр: текст который вставится если переменная ничего не вернула")
                            imgui.PopFont()
                        }
                imgui.EndGroup()
            imgui.EndChild()

            if animations::button(
                "Закрыть##binder::getPopupRenderer.close",
                imgui.ImVec2(imgui.GetWindowWidth() - 10, 30)
                ) {
                    imgui.CloseCurrentPopup()
                }
        imgui.EndGroup()

        popup.size = imgui.GetItemRectSize() + imgui.ImVec2(10, 10)
    }
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

                self::sendString(bind.commandName, bind.value, arguments, bind.delay)
            })
        }

        HotKey::new("binderIndex" .. index, bind.keys)::registerCallback(fn {
            self::sendString(bind.commandName, bind.value, nil, bind.delay)
        })
    }
}

return binder
