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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_PLOT_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_PLOT_H

#include "plugin/types/simple.h"
#include <string>
#include <vector>
#include <cstdint>
#include <functional>
#include <imgui.h>

namespace plugin::gui::windows::main::widgets {

/// Represents plot widget in the main window.
///
/// Simple plot with descriptions for each line and with custom value formatter.
class plot final {
public:
    using value_t = std::uint32_t;                                 ///< Plot's line value.
    using value_formatter_t = std::function<std::string(value_t)>; ///< Value formatter callback.
private:
    static constexpr types::zstring_t empty_text = "Статистика отсутствует";
    static constexpr float empty_text_font_size = 18;

    struct line_t final {
        std::string description = "";
        value_t value = 0;
    }; // struct line_t final

    value_formatter_t value_formatter = [](value_t value) { return std::to_string(value); };
    std::vector<line_t> lines;

    auto get_line_size(const line_t& line, const ImVec2& plot_size, value_t max_value) const -> ImVec2;
public:
    /// Set new value formatter callback.
    ///
    /// @param new_value_formatter[in] New formatter callback.
    inline auto set_value_formatter(value_formatter_t new_value_formatter) -> void;
    
    /// Set descriptions for lines. You may want to call it after widget construction: not in the render part.
    ///
    /// @note                   Size of the `descriptions` must equal to the constructor parameter `max_lines`.
    /// @param descriptions[in] Descriptions for the lines.
    auto set_lines_descriptions(const std::vector<std::string>& descriptions) -> void;

    /// Set values for the lines. You may want to call it before rendering plot: in the render part.
    ///
    /// @note             Size of the `values` must equal to the constructor parameter `max_lines`.
    /// @param values[in] Values for the lines.
    auto set_values(const std::vector<value_t>& values) -> void;

    /// Render plot with specific size.
    ///
    /// @param size[in] Size of the plot.
    auto render(const ImVec2& size) -> void;

    /// Construct plot with constant number of maximum lines.
    ///
    /// @param max_lines[in] Max lines of the plot.
    explicit plot(std::uint8_t max_lines)
        : lines(max_lines) {}
}; // class plot final

} // namespace plugin::gui::windows::main::widgets

inline auto plugin::gui::windows::main::widgets::plot::set_value_formatter(value_formatter_t new_value_formatter) -> void {
    value_formatter = std::move(new_value_formatter);
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_PLOT_H
