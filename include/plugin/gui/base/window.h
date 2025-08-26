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
///
/// @file include/plugin/gui/window.h
/// @details Provides the base class for GUI windows in the plugin.

#ifndef GADMIN_PLUGIN_GUI_BASE_WINDOW_H
#define GADMIN_PLUGIN_GUI_BASE_WINDOW_H

#include "plugin/samp/events/event.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <minwindef.h>
#include <memory>

namespace plugin {

class gui_initializer;

namespace gui {

/// @class window
/// @brief Base class for GUI windows.
class window {
private:
    bool rendering = true;
public:
    types::not_null<gui_initializer*> child;
    
    /// @brief Virtual destructor for the window class.
    virtual ~window() = default;
    
    /// @brief Window configuration: the window's ID.
    /// @return Window's ID.
    virtual inline auto get_id() const -> types::zstring_t;
    
    /// @brief Window configuration: the window's name.
    /// @return Window's name.
    virtual inline auto get_name() const -> types::zstring_t;

    /// @brief Window configuration: if the window should render when the game is paused.
    /// @return True if the window should render on game pause, false otherwise.
    virtual inline auto render_on_game_paused() const -> bool;
    
    /// @brief Window configuration: if the window can be rendered.
    /// @return True if the window can be rendered, false otherwise.
    inline auto can_render() const -> bool;
    
    /// @brief Called each frame and so safe to render ImGui in this function.
    virtual auto render() -> void = 0;
    
    /// @brief Handles window events.
    /// @param message The message code.
    /// @param wparam Additional message information.
    /// @param lparam Additional message information.
    /// @return True if the event was handled, false otherwise.
    virtual auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool;

    /// @brief Handles samp events.
    /// @param event The event information.
    /// @return True if the event was handled, false otherwise.
    virtual auto on_event(const samp::event_info& event) -> bool;

    /// @brief Called only once when samp is fully initialized.
    virtual auto on_samp_initialize() -> void {}

    /// @brief Stop render of the current window.
    void stop_render() noexcept;

    /// @brief Constructor for all windows. When constructed, it writes in the log file that this window is initialized.
    /// @param child Child class (GUI initializer) for current window.
    /// @param id Window ID.
    explicit window(types::not_null<gui_initializer*> child, types::zstring_t id);
}; // class window

/// @brief RAII pointer to the window.
using window_ptr_t = std::unique_ptr<window>;

} // namespace gui
} // namespace plugin

inline auto plugin::gui::window::get_id() const -> types::zstring_t {
    return "<unknown window>";
}

inline auto plugin::gui::window::get_name() const -> types::zstring_t {
    return "Неизвестное окно";
}

inline auto plugin::gui::window::render_on_game_paused() const -> bool {
    return false;
}

inline auto plugin::gui::window::can_render() const -> bool {
    return rendering;
}

#endif // GADMIN_PLUGIN_GUI_BASE_WINDOW_H
