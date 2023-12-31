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

static __style__ = {
    windows = {}
    def     = {}
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
                //! data[1]: string         - Property name
                //! data[2]: table|number   - Value
                if type(data[2]) == "table" {
                    result[data[1]] = imgui[(#data[2] == 2) ? "ImVec2" : "ImVec4"](table.unpack(data[2]))
                } else {
                    result[data[1]] = data[2]
                }
            }
            return result
        })()

        //! Why not just `@import "imgui.StyleChanger"`?
        //! Reason is simple: this will cause table overflow, and later - stack overflow.
        //! Why this will cause overflow? I don't know.
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
        STYLE_TYPE_IMVEC4 => { imgui.GetStyle().Colors[imgui.Col[key]] = value }
    }
}

/**
 * Apply globaly ImGui theme.
 * @return void
 */
method __style__::apply() {
    imgui.SwitchContext()

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
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "TitleBg", imgui.ImVec4(0.12, 0.12, 0.12, 1.00))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "TitleBgActive", imgui.ImVec4(0.12, 0.12, 0.12, 1.00))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "TitleBgCollapsed", imgui.ImVec4(0.12, 0.12, 0.12, 1.00))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "MenuBarBg", imgui.ImVec4(0.12, 0.12, 0.12, 1.00))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "ScrollbarBg", imgui.ImVec4(0.12, 0.12, 0.12, 1.00))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "ScrollbarGrab", common::convertHex2ImVec4("424242"))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "ScrollbarGrabHovered", common::convertHex2ImVec4("555554"))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "ScrollbarGrabActive", common::convertHex2ImVec4("333333"))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "CheckMark", imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "SliderGrab", common::convertHex2ImVec4("222222"))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "SliderGrabActive", common::convertHex2ImVec4("222222"))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "Button", common::convertHex2ImVec4("424242"))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "ButtonHovered", common::convertHex2ImVec4("555554"))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "ButtonActive", common::convertHex2ImVec4("333333"))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "Header", common::convertHex2ImVec4("5B5B5B"))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "HeaderHovered", common::convertHex2ImVec4("838383"))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "HeaderActive", common::convertHex2ImVec4("424242"))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "Separator", imgui.ImVec4(0.47, 0.47, 0.47, 1.00))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "SeparatorHovered", imgui.ImVec4(0.47, 0.47, 0.47, 1.00))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "SeparatorActive", imgui.ImVec4(0.47, 0.47, 0.47, 1.00))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "Tab", imgui.ImVec4(0.12, 0.12, 0.12, 1.00))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "TabHovered", imgui.ImVec4(0.28, 0.28, 0.28, 1.00))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "TabActive", imgui.ImVec4(0.30, 0.30, 0.30, 1.00))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "TabUnfocused", imgui.ImVec4(0.07, 0.10, 0.15, 0.97))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "TabUnfocusedActive", imgui.ImVec4(0.14, 0.26, 0.42, 1.00))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "TextSelectedBg", imgui.ImVec4(1.00, 0.00, 0.00, 0.35))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "DragDropTarget", imgui.ImVec4(1.00, 1.00, 0.00, 0.90))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "NavHighlight", imgui.ImVec4(0.26, 0.59, 0.98, 1.00))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "NavWindowingHighlight", imgui.ImVec4(1.00, 1.00, 1.00, 0.70))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "NavWindowingDimBg", imgui.ImVec4(0.80, 0.80, 0.80, 0.20))
    self::setDefaultValue(STYLE_TYPE_IMVEC4, "ModalWindowDimBg", imgui.ImVec4(0.00, 0.00, 0.00, 0.70))
}

return __style__
