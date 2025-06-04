/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2024-2025 The Contributors.
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
///
/// @file include/plugin/gui/widgets/text.h
/// @details Provides functionality for rendering text in the GUI.

#ifndef GADMIN_PLUGIN_GUI_WIDGETS_TEXT_H
#define GADMIN_PLUGIN_GUI_WIDGETS_TEXT_H

#include "plugin/types/simple.h"
#include <cstdint>
#include <format>
#include <imgui.h>

namespace plugin::gui::widgets {

/// @struct basic_text
/// @brief Represents text widget with customizable properties.
struct basic_text final {
    types::zstring_t text;
    std::uint8_t border_size = 0;
    ImFont* font;

    /// @struct colors_t
    /// @brief Contains color settings for the text.
    struct colors_t {
        ImVec4 text = ImGui::GetStyle().Colors[ImGuiCol_Text];
        ImVec4 border = { 0, 0, 0, 1 };
    } colors;

    /// @brief Renders the text.
    void render() const;
}; // struct basic_text final

/// @brief Renders formatted text.
/// @tparam Args The types of the arguments.
/// @param font The font of the text.
/// @param border_size The size of the text border.
/// @param fmt The format string.
/// @param args The arguments to format.
template<typename... Args>
auto text(ImFont* font, std::uint8_t border_size, std::format_string<Args...> fmt, Args&&... args) noexcept -> void;

} // namespace plugin::gui::widgets

template<typename... Args>
auto plugin::gui::widgets::text(ImFont* font, std::uint8_t border_size, std::format_string<Args...> fmt, Args&&... args)
    noexcept -> void
{
    basic_text {
        .text = std::format(fmt, std::forward<Args>(args)...).c_str(),
        .border_size = border_size,
        .font = font
    }.render();
}

#endif // GADMIN_PLUGIN_GUI_WIDGETS_TEXT_H
