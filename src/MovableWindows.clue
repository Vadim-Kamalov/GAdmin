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

@import "game.Spectator"    => spectator
@import "imgui.Assets"      => imguiAssets

global enum {
    MV_ONLY_IN_SPECTATOR,
    MV_ONLY_NOT_IN_SPECTATOR,
    MV_DEFAULT
}

local movableWindows    = {}
local settings          = {}

local isChangingWindowPositions = false
local isAnyWindowPositionWasChanged = false
local currentViewMode = MV_DEFAULT

local viewConditions = {
    [MV_ONLY_IN_SPECTATOR] = fn { return spectator::isInSpectator() },
    [MV_ONLY_NOT_IN_SPECTATOR] = fn { return !spectator::isInSpectator() },
    [MV_DEFAULT] = fn { return true }
}

local viewDescriptions = {
    [MV_ONLY_IN_SPECTATOR] = "[1]: Отображение окон только в режиме наблюдения",
    [MV_ONLY_NOT_IN_SPECTATOR] = "[2]: Отображение окон не в режиме наблюдения",
    [MV_DEFAULT] = "[3]: Отображение всех окон"
}

addEventHandler("onWindowMessage", fn(msg, wparam, lparam) {
    if isChangingWindowPositions {
        if msg == wm.WM_SYSKEYDOWN || msg == wm.WM_KEYDOWN {
            local keys = {
                [VK_1] = MV_ONLY_IN_SPECTATOR,
                [VK_2] = MV_ONLY_NOT_IN_SPECTATOR,
                [VK_3] = MV_DEFAULT
            }

            if keys[wparam] {
                currentViewMode = keys[wparam]
                sampAddChatMessage("Режим отображения окон переключен: " .. viewDescriptions[currentViewMode], -1)
                consumeWindowMessage(true, false)
            } elseif wparam == vkeys.VK_ESCAPE {
                movableWindows.executeChangePositions()
                consumeWindowMessage(true, false)
            }
        }
    }
})

/**
 * @return boolean Whether the window repositioning mode is enabled.
 */
movableWindows.isChangingWindowPositions = fn { return isChangingWindowPositions }

/**
 * @return boolean Whether the position of any window has changed.
 */
movableWindows.isAnyWindowPositionWasChanged = fn { return isAnyWindowPositionWasChanged }

/**
 * @return table Table with window positions by their key.
 */
movableWindows.getUpdatedConfigWithPositions = fn { return settings.config.movableWindows }

/**
 * @return number MV_ONLY_IN_SPECTATOR | MV_ONLY_NOT_IN_SPECTATOR | MV_DEFAULT
 */
movableWindows.getCurrentViewMode = fn { return currentViewMode }

/**
 * Writes the settings from the function argument to the module's local environment, writes the position of windows by default
 * to the transferred configuration file (previously translated into a table) and adds keys to the global table in table `windows`
 *
 * Module configuration device:
 * ```clue
 * {
 *      config: Table,
 *      windows: Table {
 *          KEY = {
 *              description: String,
 *              type: Number,
 *              defaultPos: Table { x: Number, y: Number}
 *              condition: () -> Boolean
 *         }
 *     }
 * }
 * ```
 * 
 * @param _settings table
 * @return MovableWindows
 */
movableWindows.init = fn(_settings) {
    settings = _settings
    for key, data of settings.windows {
        if !settings.config.movableWindows[key] { settings.config.movableWindows[key] = data.defaultPos }
        if !_G[key] { _G[key] = key }
    }
    return movableWindows
}

/**
 * Turns on the window position changing mode, turns on the cursor and displays brief information about the modes.
 * To turn off - you need to call the function again or press ESC directly in the game.
 * 
 * @see MovableWindows.init
 * @return void
 */
movableWindows.executeChangePosition = fn {
    isChangingWindowPosition = !$
    imguiAssets::switchCursorStatus()

    if isChangingWindowPosition {
        sampAddChatMessage("Используйте клавиши на клавиатуре [1-3] чтобы переключаться между режимами:", -1)
        for _, viewModeDescription in viewDescriptions {
            sampAddChatMessage(string.rep(" ", 4) .. viewModeDescription, -1)
        }
        sampAddChatMessage("Чтобы выйти из режима редактирования, нажмите ESC.", -1)
    }
}

/**
 * Creates a window whose position can be changed through a separate mode. With the mode enabled, it will be possible to change
 * the position of the window by holding it by adding `MouseDelta`, also on hover, displays a brief description of what
 * what this window does. It snaps to the center by `x` and `y` (within the "magnet" radius - 5), sides and corners of the window.
 *
 * @see MovableWindows.init
 * @see MovableWindows.executeChangePositions
 * 
 * @param key string            Window key (see device configuration in MovableWindows.init).
 * @param callback function     A function that is called every frame. `self` takes a table as an argument
 *                              which has the following key values:
 *                              HideCursor: Boolean = _G.cursorStatus; windowPosition: ImVec2 = imgui.ImVec2(x, y)
 *                              isChangingWindowPositions: Boolean = isChangingWindowPositions;
 *                              getWindowInformation: () -> Table { isFocused: Boolean, isHovered: Boolean, size: ImVec2, rounding: Number };
 *                              Note that in the window body itself (meaning "...": imgui.Begin() ... imgui.End())
 *                              pass the `main` key to the `getWindowInformation` function, the total will be
 *                              self.main = self.getWindowInformation()
 *                              This is necessary so that the position of the window can be changed. Also, as a window position
 *                             pass `self.windowPosition`. This is necessary again - in order for the position of the window to be changed.
 */
movableWindows.newWindow = fn(key, callback) {
    return imgui.OnFrame(fn {
        return (!isGamePaused() && settings.windows[key].condition() && viewConditions[settings.windows[key].type]())
            || (isChangingWindowPositions && (currentViewMode == settings.windows[key].type || currentViewMode == MV_DEFAULT))
    }, fn(self) {
        self.HideCursor                 = imguiAssets::isCursorActive()
        self.windowPosition             = imgui.ImVec2(settings.config.movableWindows[key].x, settings.config.movableWindows[key].y)
        self.isChangingWindowPositions  = isChangingWindowPositions
        self.main                       = {}
        self.getWindowInformation       = fn {
            return {
                isFocused   = imgui.IsWindowFocused(),
                isHovered   = imgui.IsWindowHovered(),
                size        = imgui.GetWindowSize(),
                rounding    = imgui.GetStyle().WindowRounding
            }
        }

        callback(self)

        if isChangingWindowPositions {
            if self.main.isHovered {
                local dl = imgui.GetBackgroundDrawList()
                dl::AddRectFilled(
                    imgui.ImVec2(self.windowPosition.x - 2, self.windowPosition.y - 25),
                    imgui.ImVec2(self.windowPosition.x + self.main.size.x + 2, self.windowPosition.y + self.main.size.y + 2),
                    0xAAFFFFFF,
                    self.main.rounding
                )
                dl::AddText(imgui.ImVec2(self.windowPosition.x + 2, self.windowPosition.y - 18), 0xFF000000, settings.windows[key].description)
            }

            if imgui.IsMouseDown(0) && self.main.isFocused {
                local sw, sh = getScreenResolution()
                local posX, posY =
                    settings.config.movableWindows[key].x + imgui.GetIO().MouseDelta.x,
                    settings.config.movableWindows[key].y + imgui.GetIO().MouseDelta.y
                local sizeX, sizeY = self.main.size.x, self.main.size.y

                local centerOffsetX = math.floor((sw - sizeX) / 2)
                if math.abs(posX - centerOffsetX) <= 5 {
                    posX = centerOffsetX
                } elseif math.abs(posX - centerOffsetX - sizeX) <= 5 {
                    posX = centerOffsetX + sizeX
                }

                local centerOffsetY = math.floor((sh - sizeY) / 2)
                if math.abs(posY - centerOffsetY) <= 5 {
                    posY = centerOffsetY
                } elseif math.abs(posY - centerOffsetY - sizeY) <= 5 {
                    posY = centerOffsetY + sizeY
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

                isAnyWindowPositionWasChanged           = true
                settings.config.movableWindows[key].x   = posX
                settings.config.movableWindows[key].y   = posY
            }
        }
    })
}
