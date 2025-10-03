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

/// Base class for all windows.
///
/// Serves as the foundation for all windows in the GUI, enabling rendering, SA:MP event
/// and window's messages handling. Implementations must have next properties set using
/// next overriden functions:
///
///     - window::get_id():   Window's ID;
///     - window::get_name(): Window's name;
///
///     - window::render_on_game_paused(): Whether window should be rendering while game
///                                        is paused (optional, default = false);
///     
///     - window::without_background(): Whether window's background should be hidden (default = false);
///
/// Implementations may verify the user's `/alogin` state and check if the window is
/// enabled in the configuration.
class window {
private:
    bool rendering = true;
public:
    virtual ~window() = default;
    
    /// Valid instance of the GUI initializer used to create window.
    types::not_null<gui_initializer*> child;
    
    /// Window configuration: get window's ID.
    /// 
    /// @return Window's ID.
    virtual inline auto get_id() const -> types::zstring_t;
    
    /// Window configuration: get window's name.
    /// 
    /// @return Window's name.
    virtual inline auto get_name() const -> types::zstring_t;

    /// Window configuration, optional: if the window should render when the game is paused.
    /// 
    /// @return True if the window should render on game pause.
    virtual inline auto render_on_game_paused() const -> bool;

    /// Window configuration, optional: if the window's background should be hidden.
    ///
    /// @return True if the windows's background should be hidden.
    virtual inline auto without_background() const -> bool;

    /// Check whether the window can be rendered.
    /// 
    /// @return True if the window can be rendered.
    inline auto can_render() const -> bool;
    
    /// Render window. Must be called each frame.
    virtual auto render() -> void = 0;
    
    /// Process window's message.
    ///
    /// @param message[in]            Message ID.
    /// @param wparam[in], lparam[in] Message parameters.
    /// @return                       Whether the message should continue processing.
    virtual auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool;

    /// Process SA:MP event.
    /// 
    /// @param event[in] SA-MP event information.
    /// @return          Whether the event should continue processing.
    virtual auto on_event(const samp::event_info& event) -> bool;

    /// Process SA:MP initializing. Can be called only once since the plugin initialization.
    virtual auto on_samp_initialize() -> void {}

    /// Stop rendering window.
    auto stop_render() noexcept -> void;

    /// Constructs window and write in the log file that this window is initialized.
    /// 
    /// @param child[in] Valid instance of the GUI initializer used to create window.
    /// @param id[in]    Window's ID.
    explicit window(types::not_null<gui_initializer*> child, types::zstring_t id);
}; // class window

/// RAII pointer to the window.
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

inline auto plugin::gui::window::without_background() const -> bool {
    return false;
}

inline auto plugin::gui::window::can_render() const -> bool {
    return rendering;
}

#endif // GADMIN_PLUGIN_GUI_BASE_WINDOW_H
