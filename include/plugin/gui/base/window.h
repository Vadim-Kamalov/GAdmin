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

/// @file include/plugin/gui/window.h
/// @details Provides the base class for GUI windows in the plugin.

#ifndef GADMIN_PLUGIN_GUI_BASE_WINDOW_H
#define GADMIN_PLUGIN_GUI_BASE_WINDOW_H

#include "plugin/samp/events/event.h"
#include "plugin/types/simple.h"
#include <memory>
#include <minwindef.h>

namespace plugin::gui {

/// @class window
/// @brief Base class for GUI windows.
class window {
private:
    bool rendering = true;
public:
/// @brief Virtual destructor for the window class.
    virtual ~window() = default;
    
    virtual constexpr types::zstring_t get_id() const = 0;

/// @brief Determines if the window should render when the game is paused.
/// @return True if the window should render on game pause, false otherwise.
    virtual constexpr bool render_on_game_paused() const;
    
    virtual void render() = 0;
    
/// @brief Handles window events.
/// @param message The message code.
/// @param wparam Additional message information.
/// @param lparam Additional message information.
/// @return True if the event was handled, false otherwise.
    virtual bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam);

/// @brief Handles samp events.
/// @param event The event information.
/// @return True if the event was handled, false otherwise.
    virtual bool on_event(const samp::event_info& event);
    virtual void on_samp_initialize() {}

/// @brief Checks if the window can be rendered.
/// @return True if the window can be rendered, false otherwise.
    constexpr bool can_render() const;
    void stop_render() noexcept;
}; // class window

using window_ptr_t = std::unique_ptr<window>;

} // namespace plugin::gui

constexpr bool
plugin::gui::window::render_on_game_paused() const {
    return false;
}

/// @brief Checks if the window can be rendered.
/// @return True if the window can be rendered, false otherwise.
constexpr bool
plugin::gui::window::can_render() const {
    return rendering;
}

#endif // GADMIN_PLUGIN_GUI_BASE_WINDOW_H
