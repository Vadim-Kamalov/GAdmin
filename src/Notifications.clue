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

@import "Icons"     => icons
@import "Config"    => config
@import "Common"    => common

static __notifications__ = {
    active  = true
    root    = {}
}

/**
 * @return table All notifications: `[index: Number] = value: Table`. 
 */
method __notifications__::get() {
    return self.root
}

/**
 * Send notification. `notification` table device:
 *
 * ```clue
 * {
 *     icon         = Icon|nil
 *     iconColor    = ImVec4|nil
 *     title        = String|nil
 *     text         = String|nil
 *     duration     = Number|nil
 *     condition    = Function|nil
 *     buttons      = Table|nil: {
 *         first    = {
 *             text = String
 *             call = Function|nil
 *         }
 *         second   = {
 *             text = String
 *             call = Function|nil
 *         }
 *     }
 * }
 * ```
 * 
 * @param notification          table|nil
 * @param preferScriptMessage   string|nil If passed string then function will notify using `sampAddChatMessage` function.
 * @return void
 */
method __notifications__::send(notification = {}, scriptMessage) {
    if scriptMessage {
        return common::sendScriptMessage(scriptMessage)
    }

    if config.root.windows.notifications.use && #self.root < config.root.windows.notifications.maxItems {
        table.insert(self.root, {
            icon        = notification.icon || icons.ICON_HOME_EMPTY
            iconColor   = notification.iconColor || imgui.ImVec4(1, 1, 1, 1)
            title       = notification.title || "Title"
            text        = notification.text || "Description"
            duration    = notification.duration || 5
            clock       = os.clock()
            pos         = 0
            buttons     = notification.buttons
            condition   = notification.condition
        })
    }
}

/**
 * Remove notification from self.root with index.
 * @param index number|nil
 * @return void
 */
method __notifications__::remove(index = 1) {
    table.remove(self.root, index)
}

return __notifications__
