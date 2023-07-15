--[[
    GAdmin - Script for administators on gambit-rp.ru
    Copyright (C) 2023 The Contributors*.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    * You can find the contributors of the GAdmin project in the < CONTRIBUTORS > file.
]]--

local vkeys = require("vkeys")
local wm    = require("windows.message")
local imgui = require("mimgui")

local module        = { _VERSION = "0.1.15072023" } ---@class MovableWindows
local settings      = {}

MV_ONLY_IN_SPECTATOR = 1
MV_ONLY_NOT_IN_SPECTATOR = 2
MV_DEFAULT = 3

local isChangingWindowPositions = false
local isAnyWindowPositionWasChanged = false
local currentViewMode = MV_DEFAULT
local viewConditions = {
    [MV_ONLY_IN_SPECTATOR] = function() return _G.isPlayerInSpectate end,
    [MV_ONLY_NOT_IN_SPECTATOR] = function() return not _G.isPlayerInSpectate end,
    [MV_DEFAULT] = function() return true end
}

local viewDescriptions = {
    [MV_ONLY_IN_SPECTATOR] = "[1]: Отображение окон только в режиме наблюдения",
    [MV_ONLY_NOT_IN_SPECTATOR] = "[2]: Отображение окон не в режиме наблюдения",
    [MV_DEFAULT] = "[3]: Отображение всех окон"
}

addEventHandler("onWindowMessage", function(msg, wparam, lparam)
    if isChangingWindowPositions then
        if msg == wm.WM_SYSKEYDOWN or msg == wm.WM_KEYDOWN then
            local keys = {
                [vkeys.VK_1] = MV_ONLY_IN_SPECTATOR,
                [vkeys.VK_2] = MV_ONLY_NOT_IN_SPECTATOR,
                [vkeys.VK_3] = MV_DEFAULT
            }

            if keys[wparam] then
                currentViewMode = keys[wparam]
                sampAddChatMessage("Режим отображения окон переключен: " .. viewDescriptions[currentViewMode], -1)
                consumeWindowMessage(true, false)
            elseif wparam == vkeys.VK_ESCAPE then
                module.executeChangePositions()
                consumeWindowMessage(true, false)
            end
        end
    end
end)

---@return boolean Whether the window repositioning mode is enabled.
function module.isChangingWindowPositions()
    return isChangingWindowPositions
end

---@return boolean Whether the position of any window has changed.
function module.isAnyWindowPositionWasChanged()
    return isAnyWindowPositionWasChanged
end

---@return table Table with window positions by their key.
function module.getUpdatedConfigWithPositions()
    return settings.config.movableWindows
end

---@return number MV_ONLY_IN_SPECTATOR | MV_ONLY_NOT_IN_SPECTATOR | MV_DEFAULT
function module.getCurrentViewMode()
    return currentViewMode
end

--- Writes the settings from the function argument to the module's local environment, writes the position of windows by default
--- to the transferred configuration file (previously translated into a table) and adds keys to the global table in table `windows`
---
--- Module configuration device:
--- ```lua
--- {
---     config: Table,
---     windows: Table {
---         KEY = {
---             description: String,
---             type: Number,
---             defaultPos: Table { x: Number, y: Number}
---             condition: () -> Boolean
---         }
---     }
--- }
--- ```
---
---@param _settings table
---@return MovableWindows
function module.init(_settings)
    settings = _settings
    for key, data in pairs(settings.windows) do
        if settings.config.movableWindows[key] == nil then
            settings.config.movableWindows[key] = data.defaultPos
        end

        if not _G[key] then
            _G[key] = key
        end
    end
    return module
end

--- Turns on the window position changing mode, turns on the cursor and displays brief information about the modes.
--- To turn off - you need to call the function again or press ESC directly in the game.
---
---@see MovableWindows.init
---@return void
function module.executeChangePositions()
    isChangingWindowPositions, _G.cursorStatus = not isChangingWindowPositions, not _G.cursorStatus
    if isChangingWindowPositions then
        sampAddChatMessage("Используйте клавиши на клавиатуре [1-3] чтобы переключаться между режимами:", -1)
        for _, viewModeDescription in ipairs(viewDescriptions) do
            sampAddChatMessage(string.rep(" ", 4) .. viewModeDescription, -1)
        end
        sampAddChatMessage("Чтобы выйти из режима редактирования, нажмите ESC.", -1)
    end
end

--- Creates a window whose position can be changed through a separate mode. With the mode enabled, it will be possible to change
--- the position of the window by holding it by adding `MouseDelta`, also on hover, displays a brief description of what
--- what this window does. It snaps to the center by `x` and `y` (within the "magnet" radius - 5), sides and corners of the window.
---
---@see MovableWindows.init
---@see MovableWindows.executeChangePositions
---
---@param key string            Window key (see device configuration in MovableWindows.init).
---@param callback function     A function that is called every frame. `self` takes a table as an argument
---                             which has the following key values:
---                             HideCursor: Boolean = _G.cursorStatus; windowPosition: ImVec2 = imgui.ImVec2(x, y)
---                             isChangingWindowPositions: Boolean = isChangingWindowPositions;
---                             getWindowInformation: () -> Table { isFocused: Boolean, isHovered: Boolean, size: ImVec2, rounding: Number };
---                             Note that in the window body itself (meaning "...": imgui.Begin() ... imgui.End())
---                             pass the `main` key to the `getWindowInformation` function, the total will be
---                             self.main = self.getWindowInformation()
---                             This is necessary so that the position of the window can be changed. Also, as a window position
---                             pass `self.windowPosition`. This is necessary again - in order for the position of the window to be changed.
---@return table imgui.OnFrame
function module.newWindow(key, callback)
    return imgui.OnFrame(function()
        return (_G.isNotGamePaused() and settings.windows[key].condition() and viewConditions[settings.windows[key].type]())
                or (isChangingWindowPositions and (currentViewMode == settings.windows[key].type or currentViewMode == MV_DEFAULT))
    end, function(self)
        self.HideCursor                 = _G.cursorStatus
        self.windowPosition             = imgui.ImVec2(settings.config.movableWindows[key].x, settings.config.movableWindows[key].y)
        self.isChangingWindowPositions  = isChangingWindowPositions
        self.main                       = {}
        self.getWindowInformation       = function()
            return {
                isFocused   = imgui.IsWindowFocused(),
                isHovered   = imgui.IsWindowHovered(),
                size        = imgui.GetWindowSize(),
                rounding    = imgui.GetStyle().WindowRounding
            }
        end

        callback(self)

        if isChangingWindowPositions then
            if self.main.isHovered then
                local dl = imgui.GetBackgroundDrawList()
                dl:AddRectFilled(
                        imgui.ImVec2(self.windowPosition.x - 2, self.windowPosition.y - 25),
                        imgui.ImVec2(self.windowPosition.x + self.main.size.x + 2, self.windowPosition.y + self.main.size.y + 2),
                        0xAAFFFFFF,
                        self.main.rounding
                )
                dl:AddText(imgui.ImVec2(self.windowPosition.x + 2, self.windowPosition.y - 18), 0xFF000000, settings.windows[key].description)
            end

            if imgui.IsMouseDown(0) and self.main.isFocused then
                local sw, sh = getScreenResolution()
                local posX, posY =
                        settings.config.movableWindows[key].x + imgui.GetIO().MouseDelta.x,
                        settings.config.movableWindows[key].y + imgui.GetIO().MouseDelta.y
                local sizeX, sizeY = self.main.size.x, self.main.size.y

                local centerOffsetX = math.floor((sw - sizeX) / 2)
                if math.abs(posX - centerOffsetX) <= 5 then
                    posX = centerOffsetX
                elseif math.abs(posX - centerOffsetX - sizeX) <= 5 then
                    posX = centerOffsetX + sizeX
                end

                local centerOffsetY = math.floor((sh - sizeY) / 2)
                if math.abs(posY - centerOffsetY) <= 5 then
                    posY = centerOffsetY
                elseif math.abs(posY - centerOffsetY - sizeY) <= 5 then
                    posY = centerOffsetY + sizeY
                end

                -- Screen Exit Checks ( for sides )
                if posX > sw - sizeX then
                    posX = sw - sizeX
                elseif posX <= 0 then
                    posX = 0
                elseif posY >= sh - sizeY then
                    posY = sh - sizeY
                elseif posY <= 0 then
                    posY = 0
                end

                -- Screen Exit Checks ( for corners )
                if posX + sizeX > sw then
                    posX = sw - sizeX
                elseif posX <= 0 then
                    posX = 0
                end

                if posY + sizeY > sh then
                    posY = sh - sizeY
                elseif posY <= 0 then
                    posY = 0
                end

                isAnyWindowPositionWasChanged           = true
                settings.config.movableWindows[key].x   = posX
                settings.config.movableWindows[key].y   = posY
            end
        end
    end)
end

return module