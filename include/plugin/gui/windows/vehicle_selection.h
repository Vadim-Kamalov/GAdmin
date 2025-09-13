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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_VEHICLE_SELECTION_H
#define GADMIN_PLUGIN_GUI_WINDOWS_VEHICLE_SELECTION_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/widgets/search.h"
#include "plugin/samp/events/event.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include "plugin/gui/gui.h"

using namespace std::chrono_literals;

namespace plugin::gui::windows {

/// Window for vehicle selection and spawning.
///
/// Provides interface for searching and selecting vehicles to spawn.
/// Supports filtering, command handling and animated display.
class vehicle_selection final : public window {
private:
    static constexpr std::chrono::milliseconds animation_duration = 500ms;
    static constexpr float create_button_height = 30;

    struct entry final {
        std::string name;
        std::uint16_t id;
    }; // struct entry final

    widgets::search search_bar = widgets::search(get_id());

    int colors[2] = { 0, 0 };
    bool closing = false, active = false, focus = false;
    std::uint8_t background_alpha = 0, window_alpha = 0;
    std::chrono::steady_clock::time_point time;

    auto on_send_command(const samp::out_event<samp::event_id::send_command>& event) -> bool;
    auto get_filtered_entries() -> std::vector<entry>;
    
    auto open_window() -> void;
    auto close_window() -> void;
public:
    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;

    /// Create vehicle selection window instance.
    ///
    /// @param child GUI initializer.
    /// @return Unique pointer to window.
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;
    auto on_event(const samp::event_info& event) -> bool override;
    auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool override;
    auto render() -> void override;

    /// Constructor.
    ///
    /// @param child GUI initializer.
    explicit vehicle_selection(types::not_null<gui_initializer*> child)
        : window(child, get_id()) {}
}; // class vehicle_selection final : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::vehicle_selection::get_id() const -> types::zstring_t {
    return "windows::vehicle_selection";
}

inline auto plugin::gui::windows::vehicle_selection::get_name() const -> types::zstring_t {
    return "Спавн машин (/veh)";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_VEHICLE_SELECTION_H
