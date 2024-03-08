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

@import "Config" => config
@import "Common" => common
@import "Assets" => assets

@import "imgui.Assets"     => imguiAssets
@import "imgui.Animations" => animations

static hotKeysCallbacks = {}
static changingHotKey   = false
static allHotKeys       = {}

static enum /** @enum HOTKEY_CONDITION */ {
    HOTKEY_CONDITION_ONLY_IN_SPECTATOR,
    HOTKEY_CONDITION_ONLY_NOT_IN_SPECTATOR,
    HOTKEY_CONDITION_ONLY_IF_CURSOR_ACTIVE,
    HOTKEY_CONDITION_ONLY_IF_CURSOR_NOT_ACTIVE,
    HOTKEY_CONDITION_ALWAYS,
    HOTKEY_CONDITION_NEVER
}

local HotKey = {}; HotKey.__index = HotKey //! @class HotKey

/**
 * Check if you can use a bind.
 *
 * @param condition HOTKEY_CONDITION
 * @return boolean
 */
method HotKey::canUseHotKey(condition) {
    return match condition {
        HOTKEY_CONDITION_ONLY_IN_SPECTATOR         => __spectator__.status,
        HOTKEY_CONDITION_ONLY_NOT_IN_SPECTATOR     => !__spectator__.status,
        HOTKEY_CONDITION_ONLY_IF_CURSOR_ACTIVE     => common::isCursorActive(),
        HOTKEY_CONDITION_ONLY_IF_CURSOR_NOT_ACTIVE => !common::isCursorActive(),
        HOTKEY_CONDITION_ALWAYS                    => true,
        HOTKEY_CONDITION_NEVER                     => false
    }
}

/**
 * Check that `key` is large. Large key is some of them:
 *  VK_SHIFT, VK_SPACE, VK_CONTROL, VK_LMENU, VK_RETURN
 *
 * @param key number
 * @return boolean
 */
method HotKey::isLargeKey(key) {
    return match key {
        VK_SHIFT    ||
        VK_SPACE    ||
        VK_CONTROL  ||
        VK_LMENU    ||
        VK_MENU     ||
        VK_LMENU    ||
        VK_RMENU    ||
        VK_RCONTROL ||
        VK_LCONTROL ||
        VK_LSHIFT   ||
        VK_RSHIFT   ||
        VK_RETURN   => true,
        default     => false
    }
}

/**
 * Sort keys. `keys` must be 1 or 2 size array.
 * In sorted table if it's size equals to 2 at first index always
 * will be large keys. For large keys, see above.
 *
 * @see HotKey::isLargeKey
 * 
 * @param keys table
 * @return void
 */
method HotKey::sortKeys(keys) {
    if #keys == 2 && !self::isLargeKey(keys[1]) && self::isLargeKey(keys[2]) {
        keys[1], keys[2] = $2, $1
    }
}

/**
 * Convert list of `keys` to their names as string using `require("vkeys").id_to_name` function.
 * 
 * @param keys table 
 * @param separator string|nil (default = " + ")
 * @return string
 */
method HotKey::keysToString(keys, separator = " + ") {
    if #keys == 0 { return "-НЕТ-" }

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
 * @param limit number|nil Limit output table to `limit` size (default = 2).
 * @return table
 */
method HotKey::getDownKeys(limit = 2) {
    local keys = {}
   
    for _, key of vkeys {
        if #keys != limit && key != VK_LBUTTON && key != VK_RBUTTON
            && key != VK_MBUTTON && key != VK_LWIN && KEY != VK_RWIN
        {
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

    self::sortKeys(keys)

    return keys
}

/**
 * Setup HotKey watcher. Only for use in onWindowMessage event!
 * @return void
 */
method HotKey::setupWatcher(event, wparam, lparam) {
    if event == wm.WM_KILLFOCUS && changingHotKey {
        self::stopChangingKeys()
    }

    if event == wm.WM_KEYDOWN || event == wm.WM_SYSKEYDOWN {
        //! Consuming window message when changing any `HotKey` keys.
        //! When pressed `VK_ESCAPE`, we will stop changing keys and reset to default keys.
        if changingHotKey {
            consumeWindowMessage(true, false)
            if wparam == VK_ESCAPE {
                self::stopChangingKeys()
            }
        } else {
            if !common::isInputsActive() {
                local key = match wparam {
                    VK_CONTROL ||
                    VK_MENU    ||
                    VK_SHIFT    => assets::mapScanCodeToVKey((lparam & 0xFF0000) >> 16),
                    default     => wparam
                }

                for _, hotKey in allHotKeys {
                    //! Implementing keys handling. Allowed length of registered keys is 2.
                    //! When this(ese) keys is(are) pressed, then we will consume this window message
                    //! and call callback that passed in `hotKeysCallbacks` table.
                    if (#hotKey.keys == 1 && key == hotKey.keys[1]) ||
                        (#hotKey.keys == 2 && isKeyDown(hotKey.keys[1]) && key == hotKey.keys[2])
                    {
                        if local item = hotKeysCallbacks[hotKey.id] {
                            if !item.keysDown && self::canUseHotKey(item.condition) {
                                item.callback()
                                item.keysDown = true

                                consumeWindowMessage(true, true)
                            }
                        }
                    }
                }
            }
        }
    } elseif event == wm.WM_KEYUP || event == wm.WM_SYSKEYUP {
        for _, hotKey in allHotKeys {
            if local item = hotKeysCallbacks[hotKey.id] {
                if item.keysDown {
                    item.keysDown = false
                }
            }
        }
    }
}

/**
 * Stop changing HotKey and reset keys to default.
 * @return void
 */
method HotKey::stopChangingKeys() {
    for id, item of UI_ANIMATED_HOTKEY {
        if item.active {
            for _, hotKey in allHotKeys {
                if id == hotKey.id {
                    hotKey::changeKeysTo(hotKey.keys)
                    item.active     = false
                    changingHotKey  = item.active
                }
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
    self::sortKeys(sourceKeys)

    for id, targetKeys of hotKeysCallbacks {
        self::sortKeys(targetKeys)
        if id != exceptId && table.concat(sourceKeys, " ") == table.concat(targetKeys.keys, " ") {
            return true, id
        }
    }
    return false, ""
}

/**
 * Create new HotKey class.
 * 
 * @param id string                     HotKey-ID, need for saving and reading keys from/in configuration file.
 * @param keys table|nil                Default keys. Can changed with `HotKey::changeKeysTo(keys)`.
 * @param description string|nil        Optional description for main window.
 * @param condition HOTKEY_CONDITION    When user can use this bind.
 * @return HotKey
 */
method HotKey::new(id, keys, description, condition = HOTKEY_CONDITION_ONLY_IF_CURSOR_NOT_ACTIVE) {
    self::sortKeys(keys)
    
    if config.root.hotKeys[id] && config.root.hotKeys.conditions[id] {
        keys      = config.root.hotKeys[id]
        condition = config.root.hotKeys.conditions[id]
    } else {
        config.root.hotKeys[id]            = keys
        config.root.hotKeys.conditions[id] = condition
    }

    local instance = {}
    
    setmetatable(instance, self)

    self.__index         = self
    instance.keys        = keys
    instance.id          = id
    instance.condition   = condition
    instance.description = description

    return instance
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
    self::sortKeys(keys)

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
            callback    = callback,
            keysDown    = false,
            condition   = self.condition
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
 * @param defaultSize       ImVec2
 * @param onChangedCallback function|nil Called when keys successfuly changed. Accepts `self` as argument.
 * @return void
 */
method HotKey::render(defaultSize = imgui.ImVec2(80, 25), onChangedCallback) {
    if !UI_ANIMATED_HOTKEY {
        global UI_ANIMATED_HOTKEY = {}
    }

    if !UI_ANIMATED_HOTKEY[self.id] {
        UI_ANIMATED_HOTKEY[self.id] = {
            label             = tostring(self),
            active            = false,
            renderOn          = imgui.new.int(self.condition)
            editingProperties = false,
            keys              = {},
            tick              = {
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

        if animations::button(string.format("%s##%s", buttonText, self.id), size) && !changingHotKey {
            this.active     = !$
            changingHotKey  = this.active
            this.tick.clock = os.clock()
        }

        if imgui.IsMouseReleased(1 /* ImGuiMouseButton_Right */) && imgui.IsItemHovered() {
            this.editingProperties = true
        }

        animations::hint(self.id .. ".hotKeyProperties", fn {
            return !changingHotKey && this.editingProperties
        }, nil, imgui.GetStyle().Colors[imgui.Col.ChildBg], fn {
            if !imgui.IsWindowHovered() && $IS_ANY_MOUSE_BUTTON_CLICKED && this.editingProperties {
                this.editingProperties = false
            }

            imgui.BeginGroup()
                imguiAssets::textWithFont("Условие активации", bold10)

                imgui.SetNextItemWidth(200)
                if imgui.SliderInt("##" .. self.id .. ".hotKeyProperties.slider", this.renderOn, 1, 6, ({
                    "Только в режиме наблюдения",
                    "Только НЕ в режиме наблюдения",
                    "Только если курсор активен",
                    "Только если курсор НЕ активен",
                    "Всегда",
                    "Никогда"
                })[this.renderOn[0]]) {
                    config.root.hotKeys.conditions[self.id] = this.renderOn[0]
                    self.condition                          = this.renderOn[0]
                    hotKeysCallbacks[self.id].condition     = this.renderOn[0]
                }   

                if animations::button("Сбросить бинд##hotKeyProperties.resetKeys", imgui.ImVec2(200, 30)) {
                    self::changeKeysTo({})
                }
            imgui.EndGroup()
        }, 215)

        if this.active {
            if #this.keys > 0 {
                for _, key in this.keys {
                    if wasKeyReleased(key) {
                        self::changeKeysTo(this.keys)
                        
                        this.active                     = false
                        changingHotKey                  = this.active
                        hotKeysCallbacks[self.id].keys  = this.keys

                        onChangedCallback?(self)
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
