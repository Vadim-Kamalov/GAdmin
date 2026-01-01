/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2026 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_GUI_WIDGETS_TEXT_H
#define GADMIN_PLUGIN_GUI_WIDGETS_TEXT_H

#include "plugin/types/simple.h"
#include <cstdint>
#include <format>
#include <imgui.h>

namespace plugin::gui::widgets {

/// Represents text widget with customizable properties. Shouldn't be used directly:
/// you should prefer using helper-functions that constructs this structure and renders it.
struct basic_text final {
    types::zstring_t text;          ///< Text to render.
    std::uint8_t border_size = 0;   ///< Border size around the text to render. Pass `0` to disable.
    ImFont* font;                   ///< Font of the text to render.
    float font_size;                ///< Font size of the text to render.

    /// Colors for the text and border to render.
    struct colors_t {
        ImVec4 text = ImGui::GetStyle().Colors[ImGuiCol_Text];
        ImVec4 border = { 0, 0, 0, 1 };
    } colors;

    /// Render the text.
    void render() const;
}; // struct basic_text final

/// Render formatted text with specific font.
///
/// @tparam Args           Types of the arguments for formatting.
/// @param font[in]        Font of the text.
/// @param border_size[in] Border size around the text to render. Pass `0` to disable.
/// @param fmt[in]         Format string.
/// @param args[in]        Arguments to format.
template<typename... Args>
auto text(ImFont* font, float font_size, std::uint8_t border_size, std::format_string<Args...> fmt, Args&&... args) noexcept -> void;

} // namespace plugin::gui::widgets

template<typename... Args>
auto plugin::gui::widgets::text(ImFont* font, float font_size, std::uint8_t border_size, std::format_string<Args...> fmt, Args&&... args)
    noexcept -> void
{
    basic_text {
        .text = std::format(fmt, std::forward<Args>(args)...).c_str(),
        .border_size = border_size,
        .font = font,
        .font_size = font_size
    }.render();
}

#endif // GADMIN_PLUGIN_GUI_WIDGETS_TEXT_H
