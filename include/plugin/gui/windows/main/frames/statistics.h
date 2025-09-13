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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_STATISTICS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_STATISTICS_H

#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/gui/windows/main/widgets/plot.h"
#include "plugin/gui/windows/main/widgets/submenu.h"
#include "plugin/misc/features/statistics.h"
#include "plugin/types/not_null.h"
#include <chrono>

namespace plugin::gui::windows::main::frames {

/// Represents the statistics frame in the main window.
class statistics final : public basic_frame {
private:
    static constexpr misc::statistics_t::range_t gmt_peak_hours = { 17, 19 };
    static constexpr std::uint8_t days_in_week = 7;
    static constexpr std::uint8_t hours_in_day = 24;
    
    static constexpr types::zstring_t week_plot_title = "Статистика по дням недели";
    static constexpr types::zstring_t day_plot_title = "Статистика по часам";

    static constexpr float clear_button_height = 30;
    static constexpr float title_font_size = 24;
    static constexpr float common_font_size = 18;
    static constexpr float week_plot_font_size = 18;
    static constexpr float day_plot_font_size = 14;

    using plot_value_t = misc::statistics_t::value_t;
    using plot_key_t = misc::statistics_t::entry_type;

    enum class plot_type_t : std::uint8_t {
        time,
        number
    }; // enum class plot_type_t : std::uint8_t

    struct plot_info_t final {
        std::string label;
        misc::statistics_t::entry_type key;
        plot_type_t type = plot_type_t::number;
    }; // struct plot_info_t final

    struct time_periods_t final {
        std::uint32_t total = 0;
        std::uint32_t today = 0;
        std::uint32_t week = 0;
        std::uint32_t peak = 0;
    }; // struct time_periods_t final

    static const std::vector<plot_info_t> plots;

    types::not_null<initializer*> child;
    widgets::submenu submenu = widgets::submenu("Статистика##frames::statistics");
    widgets::plot week_plot = widgets::plot(days_in_week);
    widgets::plot day_plot = widgets::plot(hours_in_day);

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    static auto date_to_ymd(const misc::statistics_t::date_t& date) -> std::chrono::year_month_day;
    static auto is_hour_range_in_peak(const misc::statistics_t::range_t& range) -> bool;
    static auto is_in_current_week(const misc::statistics_t::date_t& date) -> bool;

    auto render_day_plot(const plot_info_t& plot_info) -> void;
    auto render_week_plot(const plot_info_t& plot_info) -> void;
    auto write_week_plot_values(const plot_info_t& plot_info) -> void;
    auto format_value(const plot_type_t& type, std::uint32_t value) const -> std::string;

    auto get_time_periods(const plot_info_t& plot) const -> time_periods_t;
    auto frame_renderer(std::string& label, std::any& payload) -> void;
public:
    auto render() -> void override;

    /// Construct the frame.
    ///
    /// @param child[in] Valid pointer to the main window.
    explicit statistics(types::not_null<initializer*> child);
}; // class statistics final

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_STATISTICS_H
