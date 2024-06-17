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

@import "game.Spectator"    => spectator
@import "imgui.Assets"      => imguiAssets
@import "Config"            => config
@import "Common"            => common

@macro SETUP_EVENT_MV(msg, wparam) {
    {
        local this = __movableWindows__
        if this.changingWindowsPositions && !sampIsChatInputActive() && !sampIsDialogActive() && !isSampfuncsConsoleActive() {
            if $msg == wm.WM_SYSKEYDOWN || $msg == wm.WM_KEYDOWN {
                local keys = {
                    [VK_1] = MV_ONLY_IN_SPECTATOR,
                    [VK_2] = MV_ONLY_NOT_IN_SPECTATOR,
                    [VK_3] = MV_DEFAULT
                }

                if keys[$wparam] {
                    __movableWindows__.viewMode = keys[$wparam]
                    common::sendScriptMessage("Режим отображения окон переключен: %s", MV_VIEW_DESCRIPTIONS[this.viewMode])
                    consumeWindowMessage(true, false)
                } elseif $wparam == VK_ESCAPE {
                    this::executeChangingWindowsPositions()
                    consumeWindowMessage(true, false)
                }
            }
        }
    }
}

static enum /* MV_WINDOW_DISPLAY_TYPE */ {
    MV_ONLY_IN_SPECTATOR,
    MV_ONLY_NOT_IN_SPECTATOR,
    MV_DEFAULT
}

static __movableWindows__ = {
    changingWindowsPositions = false,
    viewMode = MV_DEFAULT,
    handlerRegistered = false,
}

static MV_VIEW_DESCRIPTIONS = {
    [MV_ONLY_IN_SPECTATOR]      = "[1]: Отображение окон только в режиме наблюдения",
    [MV_ONLY_NOT_IN_SPECTATOR]  = "[2]: Отображение окон не в режиме наблюдения",
    [MV_DEFAULT]                = "[3]: Отображение всех окон"
} 

local MV_VIEW_CONDITIONS = {
    [MV_ONLY_IN_SPECTATOR]      = fn { return spectator.status }
    [MV_ONLY_NOT_IN_SPECTATOR]  = fn { return !spectator.status }
    [MV_DEFAULT]                = fn { return true }
}

/**
 * @return boolean Wheather is changing windows position.
 */
method __movableWindows__::isChangingWindowsPositions() {
    return self.changingWindowsPositions
}

/**
 * Call up a change of window positions. Enables ImGui cursor if it was switched off. 
 * To switch off the window position change, press the ESC key in the game or call this function again.
 *
 * @return void
 */
method __movableWindows__::executeChangingWindowsPositions() {
    self.changingWindowsPositions = !$
    imguiAssets::switchCursorStatus()

    if self.changingWindowsPositions {
        common::sendScriptMessage("Используйте клавиши на клавиатуре [1-3] чтобы переключаться между режимами:")
        for _, viewModeDescription in MV_VIEW_DESCRIPTIONS {
            common::sendScriptMessage("%s%s", string.rep(" ", 4), viewModeDescription)
        }
        common::sendScriptMessage("Чтобы выйти из режима редактирования, нажмите ESC.")
    }
}

/**
 * Setup the window for changing positions using this module.
 * Must called only in `imgui.OnFrame` function: in callback-parameter.
 *
 * `window` configuration device:
 * ```clue
 * {
 *     pos          = { x = Number, y = Number },
 *     size         = { x = Number, y = Number },
 *     id           = String,
 *     isFocused    = Boolean,  // imgui.IsWindowFocused()
 *     isHovered    = Boolean,  // imgui.IsWindowHovered()
 *     rounding     = Number,   // imgui.GetStyle().WindowRounding 
 *     description  = String
 * }
 * ```
 *
 * @param window table
 * @return void
 */
method __movableWindows__::setupThisWindow(window) {
    if self.changingWindowsPositions {
        if window.isHovered {
            @ifdef __GADMIN_DEBUG__ {
                window.description ..= " | DEBUG("
                    .. tostring(select(1, getScreenResolution()) / window.pos.x) .. ", "
                    .. tostring(select(2, getScreenResolution()) / window.pos.y) .. ")"
            }

            local dl = imgui.GetBackgroundDrawList()
            dl::AddRectFilled(
                imgui.ImVec2(window.pos.x - 2, window.pos.y - 25),
                imgui.ImVec2(window.pos.x + window.size.x + 2, window.pos.y + window.size.y + 2),
                0xAAFFFFFF,
                window.rounding
            )
            dl::AddTextFontPtr(bold, 16, imgui.ImVec2(window.pos.x + 2, window.pos.y - 18), 0xFF000000, window.description)
        }

        if imgui.IsMouseDown(0) && window.isFocused {
            local sw, sh = getScreenResolution()
            local posX, posY =
                config.root.movableWindows[window.id].x + imgui.GetIO().MouseDelta.x,
                config.root.movableWindows[window.id].y + imgui.GetIO().MouseDelta.y
            local sizeX, sizeY = window.size.x, window.size.y

            local centerX = posX + window.size.x / 2
            local centerY = posY + window.size.y / 2
            
            if math.abs(centerX - (sw / 2)) < 5 {
                posX = math.floor(sw / 2) - window.size.x / 2
            }
            
            if math.abs(centerY - (sh / 2)) < 5 {
                posY = math.floor(sh / 2) - window.size.y / 2
            }

            // Screen Exit Checks ( for sides )
            if posX > sw - sizeX {
                posX = sw - sizeX
            } elseif posX <= 0 {
                posX = 0
            } elseif posY >= sh - sizeY {
                posY = sh - sizeY
            } elseif posY <= 0 {
                posY = 0
            }

            // Screen Exit Checks ( for corners )
            if posX + sizeX > sw {
                posX = sw - sizeX
            } elseif posX <= 0 {
                posX = 0
            }

            if posY + sizeY > sh {
                posY = sh - sizeY
            } elseif posY <= 0 {
                posY = 0
            }

            config.root.movableWindows[window.id].x = posX
            config.root.movableWindows[window.id].y = posY
        } // if imgui.IsMouseDown(0) && window.isFocused
    }
}

/**
 * Setup window condition.
 * @param type number MV_ONLY_IN_SPECTATOR | MV_ONLY_NOT_IN_SPECTATOR | MV_DEFAULT
 */
method __movableWindows__::setupThisWindowCondition(type) {
    return !isGamePaused() && MV_VIEW_CONDITIONS[type]() 
           || (self.changingWindowsPositions && (self.viewMode == type || self.viewMode == MV_DEFAULT))
}

return __movableWindows__
