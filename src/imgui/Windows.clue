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

@import "Config"            => config
@import "imgui.Assets"      => imguiAssets
@import "imgui.Style"       => style
@import "MovableWindows"    => movableWindows

/**
 * All windows that registered by this class. Array of `{ id: string, description: string }`.
 * @see ImguiWindow
 */
static registeredWindows = {}

/**
 * `windows` module, represented as class. Note that each import of this module registers this class.
 * @class ImguiWindow
 */
local windows = {}; windows.__index = windows

global enum /* WIN_DEFAULT_POS */ {
    WIN_DEFAULT_POS_CENTER
}

/**
 * Set ImGui window render status.
 * @param status boolean Render status.
 * @return void
 */
method windows::setRenderStatus(status = false) {
    self.condition = fn { return status }
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
    flags = imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar
        + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar 
        + imgui.WindowFlags.AlwaysAutoResize
) {
    self.flags = flags

    style::beginWindowStyleChangeable(self.id)
    imgui.Begin(label, nil, self.flags)
        self.window = {
            pos         = self.pos,
            isFocused   = imgui.IsWindowFocused(),
            isHovered   = imgui.IsWindowHovered(),
            size        = imgui.GetWindowSize(),
            rounding    = imgui.GetStyle().WindowRounding,
            id          = self.id,
            description = self.description
        }
        
        callback()
    imgui.End()
    style::endWindowStyleChangeable(self.id)
}

/**
 * Create a new window with the MovableWindows module.
 *
 * `configuration` example:
 * ```clue
 * {
 *     condition    = fn { return false },
 *     type         = MV_DEFAULT,
 *     defaultPos   = WIN_DEFAULT_POS_CENTER,
 *     size         = { x = 255, y = 256 },
 *     description  = "Hello, world!",
 *         
 *     // Initialisation of variables outside of the ImGui renderer without using any local variables. 
 *     // In render self-parameter it can be used as self.var.someVariable
 *     initialize = {
 *         someVariable = "Hello, world!" 
 *     }
 * }
 * ```clue
 *
 * @param id string                 Window ID. Used as config.root.movableWindows[id].
 * @param configuration table       Window configuration (for example see above).
 * @param render function           Render function that accepts `self` as argument.
 */
method windows::new(id, configuration, render) {
    self.description    = configuration.description || "No description provided"
    self.condition      = configuration.condition || (fn { return true })
    self.type           = configuration.type || MV_DEFAULT
    self.defaultPos     = configuration.defaultPos || WIN_DEFAULT_POS_CENTER
    self.id             = id
    self.var            = {}
    
    self.resolution = {
        x = select(1, getScreenResolution()),
        y = select(2, getScreenResolution())
    }

    self.executeChangingWindowsPositions    = fn { movableWindows::executeChangingWindowsPositions() }
    self.closeWindow                        = fn { self.condition = fn { return false }}

    table.insert(registeredWindows, { id = id, description = self.description })

    if configuration.initialize {
        // Initialisation of variables outside of the ImGui renderer without using any local variables.
        for key, value of configuration.initialize {
            self.var[key] = value
        }
    }

    imgui.OnFrame(fn { return movableWindows::setupThisWindowCondition(self.type) && self.condition() }, fn(window) {
        window.HideCursor = imguiAssets::getCursorStatus()
    
        self.isChangingWindowsPositions = movableWindows::isChangingWindowsPositions()
        self.size = (type(configuration.size) == "function") ? configuration.size() : (configuration.size || ({ x = 0, y = 0 }))

        imgui.SetNextWindowSize(imgui.ImVec2(self.size.x, self.size.y))

        if local pos = config.root.movableWindows[id] {
            imgui.SetNextWindowPos(imgui.ImVec2(pos.x, pos.y))
            self.pos = pos
        } else {
            config.root.movableWindows[id] = (self.defaultPos == WIN_DEFAULT_POS_CENTER) ?
                { x = (self.resolution.x - self.size.x) / 2, y = (self.resolution.y - self.size.y) / 2 } : self.defaultPos
        }

        render(self)

        movableWindows::setupThisWindow(self.window)
    })
}

return windows 
