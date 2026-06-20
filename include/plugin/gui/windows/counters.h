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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_COUNTERS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_COUNTERS_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/types/simple.h"
#include "plugin/types/not_null.h"
#include <optional>

namespace plugin::gui::windows {

/// Window for displaying in-game metrics: current FPS and ping.
class counters final : public window {
private:
    using metric_t = std::pair<std::string, std::string>;
    using metrics_t = std::deque<metric_t>;

    struct window_information_t final {
        float width = 0.0f;
        metrics_t metrics;
    }; // struct window_information_t final

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    auto insert_metric(window_information_t& window, const metric_t& metric) const -> void;
    auto get_window_information() const -> std::optional<window_information_t>;
public:
    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;
    inline auto without_background() const -> bool override;

    auto render() -> void override;

    /// Create instance of the current window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    /// @return          Unique pointer to window.
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    /// Construct the window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    explicit counters(types::not_null<gui_initializer*> child)
        : window(child, get_id()),
          bold_font(child->fonts->bold),
          regular_font(child->fonts->regular) {}
}; // class counters final : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::counters::get_id() const -> types::zstring_t {
    return "windows::counters";
}

inline auto plugin::gui::windows::counters::get_name() const -> types::zstring_t {
    return "Счетчики";
}

inline auto plugin::gui::windows::counters::without_background() const -> bool {
    return true;
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_COUNTERS_H
