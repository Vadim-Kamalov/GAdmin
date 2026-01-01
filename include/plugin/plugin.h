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

#ifndef GADMIN_PLUGIN_PLUGIN_H
#define GADMIN_PLUGIN_PLUGIN_H

#include "plugin/cheats/initializer.h"
#include "plugin/configuration.h"
#include "plugin/log.h"
#include "plugin/gui/gui.h"
#include "plugin/misc/misc.h"
#include "plugin/samp/network/event_handler.h"
#include <windows.h>
#include <fstream>
#include <winnt.h>

namespace plugin {

/// Global SA:MP event handler instance.
inline std::unique_ptr<samp::event_handler> event_handler;

/// Global configuration manager instance.
inline std::unique_ptr<configuration_initializer> configuration;

/// Global cheats handling system.
inline std::unique_ptr<cheats::initializer> cheats_initializer;

/// Global miscelanneous feature initializer.
inline std::unique_ptr<misc::initializer> misc_initializer;

/// Main plugin initialization and management class.
/// This is the main entry point of the plugin, which handles:
///
///     - Initialization;
///     - Logging;
///     - Components and subsystems initialization;
///     - Lifecycle;
///
/// Plugin can be unloaded manually when reached no-return point.
class plugin_initializer final {
private:
    std::mutex log_mutex;
    std::ofstream log_file_stream;
    std::unique_ptr<gui_initializer> gui;

    bool plugin_working = true;

    auto on_samp_initialize() -> void;
    auto on_log_message(const log::type& type, const std::string_view& message) -> void;
    auto initialize_logging() -> void;
    auto initialize_event_handler() -> void;
    auto create_and_initialize_files() -> void;
    
    static auto on_terminate() noexcept -> void;
    static auto __stdcall on_unhandled_exception(EXCEPTION_POINTERS* exception_info) noexcept -> long;
public:
    /// Unload the plugin. Sets `plugin_working` variable
    /// to `false` and waits for the `loader.cpp` response.
    auto unload() -> void;

    /// Check if plugin is active. Used internally by `loader.cpp`.
    ///
    /// @return True if plugin is active.
    auto is_active() const -> bool;

    /// Process SA:MP event.
    /// 
    /// @param event[in] SA-MP event information.
    /// @return          Whether the event should continue processing.
    auto on_event(const samp::event_info& event) -> bool;

    /// Check if `gui_initializer` can initialize interface
    /// without further problems, e.g. fonts availability.
    ///
    /// @return True if can initialize interface.
    auto can_initialize_render() const -> bool;

    /// Process SA:MP initializing. Can be called only once since the plugin initialization.
    auto on_render_initialize() -> void;
    
    /// Process frame and render GUI elements. Must be called each frame!
    auto on_frame() -> void;

    /// Process window's message.
    ///
    /// @param message[in]            Message ID.
    /// @param wparam[in], lparam[in] Message parameters.
    /// @return                       Whether the message should continue processing.
    auto on_message(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool;
    
    /// Main loop.
    auto main_loop() -> void;

    /// Construct the plugin.
    explicit plugin_initializer();

    /// Destroy the plugin.
    ~plugin_initializer() noexcept;
}; // class plugin_initializer final

} // namespace plugin

#endif // GADMIN_PLUGIN_PLUGIN_H
