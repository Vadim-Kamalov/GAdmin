/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023-2025 The Contributors.
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

@import "Config"   => config
@import "Assets"   => assets
@import "Common"   => common
@import "Requests" => requests

static __style__ = {
    windows     = {}
    def         = {}
    baseColors  = {
        { "Text", nil },
        { "TextDisabled", nil },
        { "WindowBg", nil },
        { "ChildBg", nil },
        { "PopupBg", nil },
        { "Border", nil },
        { "BorderShadow", nil },
        { "FrameBg", nil },
        { "FrameBgHovered", nil },
        { "FrameBgActive", nil },
        { "ScrollbarBg", nil },
        { "ScrollbarGrab", nil },
        { "ScrollbarGrabHovered", nil },
        { "ScrollbarGrabActive", nil },
        { "Button", nil },
        { "ButtonHovered", nil },
        { "ButtonActive", nil },
        { "Header", nil },
        { "HeaderHovered", nil },
        { "HeaderActive", nil },
        { "Separator", nil },
        { "SeparatorHovered", nil },
        { "SeparatorActive", nil },
        { "TextSelectedBg", nil }
    }
}

local enum /* STYLE_TYPE */ {
    STYLE_TYPE_NUMBER,
    STYLE_TYPE_IMVEC2,
    STYLE_TYPE_IMVEC4
}

/**
 * Register window and insert it in `registeredWindows` array. We need this method when
 * we need to create new style changeable window without creating `ImguiWindow` class.
 *
 * @see ImguiWindow
 *
 * @param id string             Window identifier that will used in config.
 * @param description string    Window description.
 * @return void
 */
method __style__::registerWindow(id, description) {
    table.insert(registeredWindows, { id = id, description = description })
    config.root.styleChangeableWindows[id] ??= {}
}

/**
 * Allow next window be style changeable. Must called before using `imgui.Begin(...)` function.
 * After `imgui.End()` must called `style::endWindowStyleChangeable(id)` function.
 *
 * @param id string Window-ID.
 * @return void
 */
method __style__::beginWindowStyleChangeable(id) {
    if local this = config.root.styleChangeableWindows[id] {
        local style = (fn {
            local result = {}
            for _, data in this {
                //! data[1]: string              - Property name
                //! data[2]: table|number|string - Value
                if type(data[2]) == "table" {
                    result[data[1]] = imgui[(#data[2] == 2) ? "ImVec2" : "ImVec4"](table.unpack(data[2]))
                } elseif type(data[2]) == "string" {
                    result[data[1]] = common::convertHex2ImVec4(data[2])
                } else {
                    result[data[1]] = data[2]
                }
            }
            return result
        })()

        //! Why not just `@import "imgui.StyleChanger"`?
        //! Reason is simple: this will cause table overflow, and later - stack overflow.
        //! Why this will cause overflow? I don't know. (now I know - it's cyclic dependency of modules)
        //!
        //! This check (`??=`) is needed to prevent import spam.
        self.windows[id] ??= import("imgui.StyleChanger")::new(style)

        self.windows[id]::update(style)
        self.windows[id]::apply()
    }
}

/**
 * Just reset window style after changing by `style::beginWindowStyleChangeable(id)`.
 * @param id string Window-ID.
 * @return void
 */
method __style__::endWindowStyleChangeable(id) {
    if config.root.styleChangeableWindows[id] {
        self.windows[id]::reset()
    }
}

/**
 * Set ImGui style (from key to value) with putting value in __style__.def (we need this for StyleChanger.clue).
 *
 * @param type number STYLE_TYPE
 * @param key string
 * @param value ImVec2|Number|ImVec4
 * @return void
 */
method __style__::setDefaultValue(type, key, value) {
    self.def[key] = value

    match type {
        STYLE_TYPE_NUMBER || STYLE_TYPE_IMVEC2 => { imgui.GetStyle()[key] = value }
        STYLE_TYPE_IMVEC4 => {
            for _, property in self.baseColors {
                if property[1] == key {
                    property[2] = { value.x, value.y, value.z, value.w }
                    break
                }
            }

            imgui.GetStyle().Colors[imgui.Col[key]] = value
        }
    }
}

method __style__::getBaseColors() {
    return assets::copyTable(self.baseColors)
}

/**
 * Download theme from `link` and load it using `loadThemeFromXML`.
 *
 * @param link string
 * @return void
 */
method __style__::downloadTheme(link) {
    lua_thread.create(fn {
        requests::asyncHttpRequest("GET", link, {}, fn (response) {
            if response.status_code == 200 {
                self::loadThemeFromXML(response.text)
                common::sendScriptMessage("Тема успешно установлена! Скрипт перезагрузится.")
                thisScript()::reload()
            } else {
                common::sendScriptMessage("Не удалось установить тему. Попробуйте еще раз.")
            }
        }, fn (error) {
            common::sendScriptMessage("Не удалось установить тему. Попробуйте еще раз.")
            common::sendScriptMessage("Ошибка - %s", error)
        })
    })
}

/**
 * Load ImGui theme from the XML file. See `themes/Defaultxml`.
 *
 * @param content string
 * @return void
 */
method __style__::loadThemeFromXML(content) {
    local handler = require("xmlhandler.tree")
    local parser  = xml2lua.parser(handler)
    
    local convertStringToReadable = fn (value) {
        if local color = string.match(value, "^#(%x+)$") {
            local vector = common::convertHex2ImVec4(color)
            return { vector.x, vector.y, vector.z, vector.w }
        } elseif string.find(value, "^{.+}$") {
            local values = {}
            for value with string.gmatch(value, "[%d%.]+") {
                table.insert(values, tonumber(value))
            }
            return values
        } else {
            return tonumber(value)
        }
    }

    parser::parse(content)

    if local globalTheme = handler.root.UserTheme["global"] {
        config.root.globalTheme = {}
        for index, section in ({ globalTheme.colors || {}, globalTheme.values || {} }) {
            for _, property in assets::getXMLElements(section, (index == 1) ? "color" : "value") {
                local value = convertStringToReadable(property[1])
                local style = (type(value) == "table") ? ((#value == 2) ? STYLE_TYPE_IMVEC2 : STYLE_TYPE_IMVEC4)
                    : STYLE_TYPE_NUMBER

                if type(value) == "table" {
                    self::setDefaultValue(style, property._attr.name, imgui[(#value == 2) ? "ImVec2" : "ImVec4"](table.unpack(value)))
                } else {
                    self::setDefaultValue(style, property._attr.name, value)
                }

                config.root.globalTheme[property._attr.name] = value
            }
        }
    }

    config.root.styleChangeableWindows = {}

    if local it = handler.root.UserTheme.windows {
        for _, window in assets::getXMLElements(it, "window") {
            for _, registeredWindow in registeredWindows {
                if string.match(registeredWindow.id, "^imgui%.windows%.(.+)") == window._attr.name {
                    local id = registeredWindow.id
                    config.root.styleChangeableWindows[id] = {}
                    
                    for index, section in ({ window.colors || {}, window.values || {} }) {
                        //! FIXME: this will throw an error if `windows.values["value"]` is null.
                        for _, property in assets::getXMLElements(section, (index == 1) ? "color" : "value") {
                            table.insert(config.root.styleChangeableWindows[id], {
                                property._attr.name,
                                convertStringToReadable(property[1])
                            })
                        }
                    }

                    break
                } 
            }
        }
    }
}

/**
 * Apply globaly ImGui theme.
 * @return void
 */
method __style__::apply() {
    imgui.SwitchContext()

    if !config.root.globalTheme {
        self::setDefaultValue(STYLE_TYPE_NUMBER, "IndentSpacing", 0)
        self::setDefaultValue(STYLE_TYPE_NUMBER, "ScrollbarSize", 10)
        self::setDefaultValue(STYLE_TYPE_NUMBER, "GrabMinSize", 10)
        self::setDefaultValue(STYLE_TYPE_NUMBER, "WindowBorderSize", 1)
        self::setDefaultValue(STYLE_TYPE_NUMBER, "ChildBorderSize", 1)
        self::setDefaultValue(STYLE_TYPE_NUMBER, "PopupBorderSize", 1)
        self::setDefaultValue(STYLE_TYPE_NUMBER, "FrameBorderSize", 1)
        self::setDefaultValue(STYLE_TYPE_NUMBER, "TabBorderSize", 1)
        self::setDefaultValue(STYLE_TYPE_NUMBER, "WindowRounding", 8)
        self::setDefaultValue(STYLE_TYPE_NUMBER, "ChildRounding", 8)
        self::setDefaultValue(STYLE_TYPE_NUMBER, "FrameRounding", 5)
        self::setDefaultValue(STYLE_TYPE_NUMBER, "PopupRounding", 5)
        self::setDefaultValue(STYLE_TYPE_NUMBER, "ScrollbarRounding", 5)
        self::setDefaultValue(STYLE_TYPE_NUMBER, "GrabRounding", 5)
        self::setDefaultValue(STYLE_TYPE_NUMBER, "TabRounding", 5)

        self::setDefaultValue(STYLE_TYPE_IMVEC2, "WindowPadding", imgui.ImVec2(5, 5))
        self::setDefaultValue(STYLE_TYPE_IMVEC2, "FramePadding", imgui.ImVec2(5, 5))
        self::setDefaultValue(STYLE_TYPE_IMVEC2, "ItemSpacing", imgui.ImVec2(5, 5))
        self::setDefaultValue(STYLE_TYPE_IMVEC2, "ItemInnerSpacing", imgui.ImVec2(2, 2))
        self::setDefaultValue(STYLE_TYPE_IMVEC2, "TouchExtraPadding", imgui.ImVec2(0, 0))
        self::setDefaultValue(STYLE_TYPE_IMVEC2, "ButtonTextAlign", imgui.ImVec2(0.5, 0.5))
        self::setDefaultValue(STYLE_TYPE_IMVEC2, "SelectableTextAlign", imgui.ImVec2(0.5, 0.5))

        self::setDefaultValue(STYLE_TYPE_IMVEC4, "Text", imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "TextDisabled", imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "WindowBg", common::convertHex2ImVec4("222222"))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "ChildBg", common::convertHex2ImVec4("2B2B2B"))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "PopupBg", common::convertHex2ImVec4("222222"))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "Border", imgui.ImVec4(0.25, 0.25, 0.26, 0.54))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "BorderShadow", imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "FrameBg", common::convertHex2ImVec4("424242"))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "FrameBgHovered", common::convertHex2ImVec4("2B2B2B"))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "FrameBgActive", common::convertHex2ImVec4("555554"))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "ScrollbarBg", imgui.ImVec4(0.12, 0.12, 0.12, 1.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "ScrollbarGrab", common::convertHex2ImVec4("424242"))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "ScrollbarGrabHovered", common::convertHex2ImVec4("555554"))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "ScrollbarGrabActive", common::convertHex2ImVec4("333333"))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "Button", common::convertHex2ImVec4("424242"))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "ButtonHovered", common::convertHex2ImVec4("555554"))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "ButtonActive", common::convertHex2ImVec4("333333"))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "Header", common::convertHex2ImVec4("5B5B5B"))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "HeaderHovered", common::convertHex2ImVec4("838383"))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "HeaderActive", common::convertHex2ImVec4("424242"))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "Separator", imgui.ImVec4(0.47, 0.47, 0.47, 1.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "SeparatorHovered", imgui.ImVec4(0.47, 0.47, 0.47, 1.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "SeparatorActive", imgui.ImVec4(0.47, 0.47, 0.47, 1.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "TextSelectedBg", imgui.ImVec4(1.00, 0.00, 0.00, 0.35))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "Tab", imgui.ImVec4(0.12, 0.12, 0.12, 1.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "TabHovered", imgui.ImVec4(0.28, 0.28, 0.28, 1.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "TabActive", imgui.ImVec4(0.30, 0.30, 0.30, 1.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "TabUnfocused", imgui.ImVec4(0.07, 0.10, 0.15, 0.97))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "TabUnfocusedActive", imgui.ImVec4(0.14, 0.26, 0.42, 1.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "DragDropTarget", imgui.ImVec4(1.00, 1.00, 0.00, 0.90))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "NavHighlight", imgui.ImVec4(0.26, 0.59, 0.98, 1.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "NavWindowingHighlight", imgui.ImVec4(1.00, 1.00, 1.00, 0.70))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "NavWindowingDimBg", imgui.ImVec4(0.80, 0.80, 0.80, 0.20))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "ModalWindowDimBg", imgui.ImVec4(0.00, 0.00, 0.00, 0.70))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "TitleBg", imgui.ImVec4(0.12, 0.12, 0.12, 1.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "TitleBgActive", imgui.ImVec4(0.12, 0.12, 0.12, 1.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "TitleBgCollapsed", imgui.ImVec4(0.12, 0.12, 0.12, 1.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "MenuBarBg", imgui.ImVec4(0.12, 0.12, 0.12, 1.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "CheckMark", imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "SliderGrab", common::convertHex2ImVec4("222222"))
        self::setDefaultValue(STYLE_TYPE_IMVEC4, "SliderGrabActive", common::convertHex2ImVec4("222222"))
    } else {
        for key, value of config.root.globalTheme {
            local style = (type(value) == "table") ? ((#value == 2) ? STYLE_TYPE_IMVEC2 : STYLE_TYPE_IMVEC4) 
                : STYLE_TYPE_NUMBER

            if type(value) == "table" {
                value = imgui[(#value == 2) ? "ImVec2" : "ImVec4"](table.unpack(value))
            }

            self::setDefaultValue(style, key, value)
        }
    }
}

return __style__
