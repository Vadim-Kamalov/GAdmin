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

@import "imgui.Windows"         => window
@import "imgui.Assets"          => imguiAssets
@import "imgui.StyleChanger"    => StyleChanger

@import "game.User" => user

@import "Config"    => config
@import "Common"    => common
@import "Icons"     => icons
@import "Assets"    => assets

static farChatMessages = {}

local sizeX, sizeY      = getScreenResolution()
local randomMessages    = {}

local fn getFarMessages(isMovingWindows) {
    math.randomseed(os.clock())

    if isMovingWindows {
        if #randomMessages != config.root.windows.farChat.maxLines {
            for i = 1, config.root.windows.farChat.maxLines {
                table.insert(randomMessages, {
                    id          = math.random(1, sampGetMaxPlayerId(false))
                    nickname    = assets.randomICNicknames[math.random(#assets.randomICNicknames)]
                    distance    = math.random(0, 20)
                    message     = assets.randomStrings[math.random(#assets.randomStrings)]
                    color       = -1
                    time        = os.date("*t")
                })
            }
        }

        return randomMessages
    } else {
        return farChatMessages
    }
}

window::new("imgui.windows.FarChat", {
    description = "Дальний чат"
    type        = MV_DEFAULT
    condition   = fn { return config.root.windows.farChat.use && user::getAloginStatus() }
    size        = { x = 0, y = 0 }
    defaultPos  = { x = 0, y = sizeY / 2 }
    initialize  = {
        style = StyleChanger::new({
            ItemSpacing         = imgui.ImVec2(0, 5)
            WindowBorderSize    = 0
            WindowPadding       = imgui.ImVec2(0, 2)
            WindowBg            = imgui.ImVec4(0, 0, 0, 0)
        })
    }
}, fn(self) {
    self.var.style::apply()
    self::begin(self.id, fn {
        local messages = getFarMessages(self.isChangingWindowsPositions)
        for i = math.max(1, #messages - (config.root.windows.farChat.maxLines - 1)), #messages {
            if local this = messages[i] {
                local strokeSize    = config.root.windows.farChat.strokeSize
                local playerColor   = common::convertHex2ImVec4($PLAYER_COLOR_TO_HEX!(this.id))
                local messageColor  = common::convertHex2ImVec4(string.format("%06X", this.color >> 8))
                local nickname      = string.gsub(this.nickname, "_", " ")

                local onNicknameClickNotify = {
                    icon    = icons.ICON_KEYBOARD
                    title   = "Скопирован никнейм"
                    text    = "Успешно скопирован никнейм игрока " .. this.nickname .. "!"
                    buttons = {
                        first = {
                            name = "Закрыть"
                            call = fn(close) { close() }
                        }

                        second = {
                            name = "Следить"
                            call = fn(close) {
                                sampSendChat("/sp " .. this.id)
                                close()
                            }
                        }
                    }
                }

                local message = this.message
                if self.isChangingWindowsPositions {
                    message = (#this.message >= 140) ? string.sub(this.message, 1, 140) .. "..." : this.message
                }

                imguiAssets::addStrokedText("> ", strokeSize, playerColor)

                if config.root.windows.farChat.displayTime {
                    local time = this.time
                    
                    imgui.SameLine()
                    imguiAssets::addStrokedText("[%02d:%02d:%02d] ", strokeSize, playerColor, time.hour, time.min, time.sec)
                }

                imgui.SameLine()
                imguiAssets::addStrokedText(nickname, strokeSize, playerColor)
                imguiAssets::setPreviousItemAbleToCopy(this.nickname, nil, nil, onNicknameClickNotify)
                
                imgui.SameLine()
                imguiAssets::addStrokedText("[%d]", strokeSize, playerColor, this.id)
                imguiAssets::setPreviousItemAbleToCopy(this.id, "Скопирован айди", "Успешно скопирован айди игрока " .. nickname .. ": " .. this.id)

                imgui.SameLine()
                imguiAssets::addStrokedText(": ", strokeSize, playerColor)

                imgui.SameLine()
                imguiAssets::addStrokedText(message, strokeSize, messageColor)
                imguiAssets::setPreviousItemAbleToCopy(this.message)
            }
        }
    })
    self.var.style::reset()
})
