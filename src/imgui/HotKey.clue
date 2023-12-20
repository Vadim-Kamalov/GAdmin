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

@import "Config" => config
@import "imgui.Animations" => animations
@import "Common" => common

static hotKeysCallbacks = {}
static changingHotKey   = false
static keysStatus       = {}
static wasDownKeys      = {}
static allHotKeys       = {}

local HotKey = {
    _hasAppended = false
}; HotKey.__index = HotKey //! @class HotKey

/**
 * Convert list of `keys` to their names as string using `require("vkeys").id_to_name` function.
 * 
 * @param keys table
 * @param separator string|nil (default = " + ")
 * @return string
 */
method HotKey::keysToString(keys, separator = " + ") {
    local stringKeys = ""

    for index, id in keys {
        local separator = (index == #keys) ? "" : separator 
        stringKeys ..= vkeys.id_to_name(id) .. separator
    }

    return stringKeys
}

/**
 * Get all keys-down. Each value of result table is VK-ID of down key.
 *
 * @param limit number|nil Limit output table to `limit` size (default = 4).
 * @return table
 */
method HotKey::getDownKeys(limit = 4) {
    local keys = {}
   
    for _, key of vkeys {
        if #keys != limit {
            if isKeyDown(key) && (
                key == VK_MENU || key == VK_CONTROL || key == VK_SHIFT || key == VK_LMENU ||
                key == VK_RMENU || key == VK_RCONTROL || key == VK_LCONTROL || key == VK_LSHIFT ||
                key == VK_RSHIFT 
            ) {
                if key != VK_MENU && key != VK_CONTROL && key != VK_SHIFT {
                    table.insert(keys, key)
                }
            }

            if isKeyDown(key) && (
                key != VK_MENU && key != VK_CONTROL && key != VK_SHIFT && key != VK_LMENU &&
                key != VK_RMENU && key != VK_RCONTROL && key != VK_LCONTROL && key != VK_LSHIFT &&
                key != VK_RSHIFT
            ) {
                table.insert(keys, key)
            }
        }
    }

    table.sort(keys)
   
    return keys
}

/**
 * Setup HotKey watcher. Only for use in onWindowMessage event!
 * @return void
 */
method HotKey::setupWatcher(wparam) {
    if local keys = self::getDownKeys() {
        if #keys > 0 && !changingHotKey {
            local isDefined, hotKeyId = self::isKeysDefined(keys)
            if isDefined && (!self.cursor || !common::isCursorActive()) && isKeyJustPressed(keys[#keys]) && !common::isInputsActive() {
                hotKeysCallbacks[hotKeyId].callback()
                consumeWindowMessage(true, true)
            }
        }
    }
}

/**
 * Check that `keys` are defined.
 *
 * @param sourceKeys table
 * @param exceptId string HotKey-ID that need to ignore.
 * @return boolean
 */
method HotKey::isKeysDefined(sourceKeys, exceptId) {
    table.sort(sourceKeys)

    for id, targetKeys of hotKeysCallbacks {
        table.sort(targetKeys)
        if id != exceptId && string.find(table.concat(sourceKeys, " "), table.concat(targetKeys.keys, " ")) {
            return true, id
        }
    }
    return false, ""
}

/**
 * Create new HotKey class.
 * 
 * @param id string                     HotKey-ID, need for saving and reading keys from/in configuration file.
 * @param keys table                    Default keys. Can changed with `HotKey::changeKeysTo(keys)`.
 * @param ignoreActiveCursor boolean    If true, key bind won't call hot key callback if `!commom::isCursorActive()` (default = true).
 * @param description string|nil        Optional description for main window.
 * @return HotKey
 */
method HotKey::new(id, keys, description, ignoreActiveCursor = true) {
    table.sort(keys)
    
    if config.root.hotKeys[id] {
        keys = config.root.hotKeys[id]
    } else {
        config.root.hotKeys[id] = keys
    }

    return setmetatable({
        keys        = keys,
        id          = id,
        cursor      = ignoreActiveCursor,
        description = description
    }, self)
}

/**
 * **Only for use in created class!**
 *
 * Convert current keys in `HotKey.keys` to string with `" + "` separator.
 * @return string
 */
method HotKey::__tostring() {
    return self::keysToString(self.keys)
}

/**
 * **Only for use in created class!**
 *
 * Change keys to received function parameter `keys`.
 * @param keys table
 * @return HotKey
 */
method HotKey::changeKeysTo(keys) {
    table.sort(keys)

    if hotKeysCallbacks[self.id].keys {
        config.root.hotKeys[self.id], self.keys, hotKeysCallbacks[self.id].keys =
            keys,
            keys,
            keys
    }

    return self
}

/**
 * **Only for use in created class!**
 *
 * Register callback that called after `HotKey.keys` are pressed.
 *
 * @param callback function.
 * @return HotKey
 */
method HotKey::registerCallback(callback) {
    if !hotKeysCallbacks[self.id] {
        hotKeysCallbacks[self.id] = {
            keys        = self.keys,
            callback    = callback
        }

        table.insert(allHotKeys, self)
    }
    return self
}

/**
 * **Only for use in created class!**
 *
 * Render HotKey ImGui frame.
 *
 * @param defaultSize ImVec2
 * @return void
 */
method HotKey::render(defaultSize = imgui.ImVec2(80, 25)) {
    if !UI_ANIMATED_HOTKEY {
        global UI_ANIMATED_HOTKEY = {}
    }

    if !UI_ANIMATED_HOTKEY[self.id] {
        UI_ANIMATED_HOTKEY[self.id] = {
            label       = tostring(self),
            active      = false,
            keysAllowed = true,
            keys        = {},
            tick        = {
                status  = false,
                clock   = os.clock()
            }
        }
    }

    if local this = UI_ANIMATED_HOTKEY[self.id] {
        local size = imgui.ImVec2(math.max(defaultSize.x, imgui.GetStyle().FramePadding.x * 2 + imgui.CalcTextSize(this.label).x), defaultSize.y)
        local buttonText = (#this.keys > 0 && !self::isKeysDefined(self::getDownKeys(), self.id)) 
            ? self::keysToString(this.keys) 
            : this.label

        if animations::button(string.format("%s##%s", buttonText, self.id), size) {
            this.active     = !$
            changingHotKey  = this.active
            this.tick.clock = os.clock()
        }

        if this.active {
            if #this.keys > 0 {
                for _, key in this.keys {
                    if wasKeyReleased(key) {
                        self::changeKeysTo(this.keys)
                        
                        this.active                     = false
                        changingHotKey                  = this.active
                        hotKeysCallbacks[self.id].keys  = this.keys
                    }
                }
            }
    
            if local keys = self::getDownKeys() {
                animations::hint("Эти клавиши уже зарегистрированы!", fn {
                    return #keys > 0 && self::isKeysDefined(keys, self.id)
                }, nil, common::convertHex2ImVec4("E46876"))

                if #keys == 0 || (#keys > 0 && self::isKeysDefined(keys, self.id)) {
                    if os.clock() - this.tick.clock >= 0.5 {
                        this.tick.status    = !$
                        this.tick.clock     = os.clock()
                    }

                    this.label = (#keys > 0) ? self::keysToString(self::getDownKeys()) : ((this.tick.status) ? "" : "Ожидание")
                } else {
                    this.label = self::keysToString(this.keys)
                    if #this.keys < #keys {
                        this.keys = keys
                    }
                }
            }
        } else {
            this.keys   = {}
            this.label  = tostring(self)
        }
    }
}

return HotKey
