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

@import "Config"            => config
@import "imgui.Assets"      => imguiAssets
@import "MovableWindows"    => movableWindows

/**
 * `windows` module, represented as class. Note that each import of this module registers this class.
 * @class ImguiWindow
 */
local windows = {}; windows.__index = windows

global enum /* WIN_DEFAULT_POS */ {
    WIN_DEFAULT_POS_CENTER
}

/**
 * Equivalent to imgui.Begin() and imgui.End(), but with predefined window flags and transmitted window information.
 *
 * @param label string      Window name.
 * @param callback function Window body.
 * @param flags ImWindowFlags
 * @return void
 */
method windows::begin(
    label,
    callback,
    flags = imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar
) {
    imgui.Begin(label, self.condition, flags)
        self.window = {
            pos         = config.root.movableWindows[self.id],
            isFocused   = imgui.IsWindowFocused(),
            isHovered   = imgui.IsWindowHovered(),
            size        = imgui.GetWindowSize(),
            rounding    = imgui.GetStyle().WindowRounding,
            id          = self.id,
            description = self.description
        }
        
        callback()
    imgui.End()
}

/**
 * Create a new window with the MovableWindows module.
 *
 * `configuration` example:
 * ```clue
 * fn {
 *     return {
 *         condition    = imgui.new.bool(config.root.windows.admins.use),
 *         type         = MV_DEFAULT,
 *         defaultPos   = WIN_DEFAULT_POS_CENTER,
 *         size         = { x = 255, y = 256 },
 *         description  = "Hello, world!",
 *         
 *         // Initialisation of variables outside of the ImGui renderer without using any local variables. 
 *         // In render self-parameter it can be used as self.var.someVariable
 *         initialize = {
 *             someVariable = "Hello, world!" 
 *         }
 *     }
 * }
 * ```clue
 *
 * @param id string                 Window ID. Used as config.root.movableWindows[id].
 * @param configuration function    Window configuration (for example see above).
 * @param render function           Render function that accepts `self` as argument.
 */
method windows::new(id, configuration, render) {
    local configuration = $()

    self.description    = configuration.description || "No description provided"
    self.condition      = configuration.condition || nil
    self.type           = configuration.type || MV_DEFAULT
    self.defaultPos     = configuration.defaultPos || WIN_DEFAULT_POS_CENTER
    self.size           = configuration.size || { x = 0, y = 0 }
    self.id             = id
    self.var            = {}
    
    self.resolution = {
        x = select(1, getScreenResolution()),
        y = select(2, getScreenResolution())
    }

    self.isChangingWindowsPositions         = movableWindows::isChangingWindowsPositions()
    self.executeChangingWindowsPositions    = fn { movableWindows::executeChangingWindowsPositions() }

    // Initialisation of variables outside of the ImGui renderer without using any local variables.
    for key, value of configuration.initialize {
        self.var[key] = value
    }

    imgui.OnFrame(fn { return movableWindows::setupThisWindowCondition(self.type) && self.condition[0] }, fn(window) {
        window.HideCursor = imguiAssets::getCursorStatus()
    
        if self.size {
            imgui.SetNextWindowSize(imgui.ImVec2(self.size.x, self.size.y))
        }

        if local pos = config.root.movableWindows[id] {
            imgui.SetNextWindowPos(imgui.ImVec2(pos.x, pos.y))
        } else {
            config.root.movableWindows[id] = (self.defaultPos == WIN_DEFAULT_POS_CENTER) ?
                { x = (self.resolution.x - self.size.x) / 2, y = (self.resolution.y - self.size.y) / 2 } : self.defaultPos
        }

        render(self)

        movableWindows::setupThisWindow(self.window)
    })
}

return windows
