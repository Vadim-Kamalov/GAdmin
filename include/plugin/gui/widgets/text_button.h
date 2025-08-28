/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
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

#ifndef GADMIN_PLUGIN_GUI_WIDGETS_TEXT_BUTTON_H
#define GADMIN_PLUGIN_GUI_WIDGETS_TEXT_BUTTON_H

#include "plugin/gui/animation.h"
#include <chrono>
#include <string>
#include <unordered_map>

using namespace std::chrono_literals;

namespace plugin::gui::widgets {

/// Represents clickable (and animated) text in the GUI..
class text_button final {
private:
    struct configuration_t final {
        animation::hover_info hover_info;
        float alpha = 0.00;
    }; // struct configuration_t final

    static inline std::unordered_map<std::string, configuration_t> pool;
    static constexpr std::chrono::milliseconds animation_duration = 300ms;
    static constexpr std::uint8_t line_height = 3;

    std::string label;
public:
    /// Render clickable text. When hovered, animation of text underlining will be applied.
    /// 
    /// @return Whether the widget is clicked or not.
    auto render() const -> bool;

    /// Construct clickable text.
    /// 
    /// @param label[in] Label of the button.
    explicit text_button(const std::string_view& label);
}; // class text_button final

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_TEXT_BUTTON_H
