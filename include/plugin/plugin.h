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
///     - Components and subsystems initialization;
///     - Lifecycle;
///
/// Plugin can be unloaded manually when reached no-return point.
class plugin_initializer final {
private:
    static constexpr auto allowed_ip_addresses = std::to_array<std::string_view>({ "5.188.224.221",
                                                                                   "85.234.65.36" });

    std::unique_ptr<gui_initializer> gui;

    auto on_samp_initialize() -> void;
    auto initialize_event_handler() -> void;
    auto create_and_initialize_files() -> void;
public:
    /// Check that the user is connected to a valid server. If this function is called
    /// when `samp::net_game::instance_container->read()` is equal to `nullptr`, it will
    /// compare the host address from the command line parameters. Otherwise, it will
    /// use `samp::net_game::get_host_address()`.
    ///
    /// Note that this function uses hardcoded IP addresses to check the connection to
    /// the valid server. The reason for this is that SA:MP does not provide the server's
    /// domain name anywhere, only its IP address. However, we could resolve the original
    /// server’s domain name to obtain the actual IP address instead of relying on hardcoded
    /// values, but this would increase the loading time, depending on the user's internet
    /// connection.
    ///
    /// Because the function implementation uses hardcoded IP addresses, we have to update
    /// these values each time any of the IP addresses changes.
    ///
    /// @see    https://github.com/Vadim-Kamalov/GAdmin/issues/38
    /// @return True if user is connected to the valid server.
    static auto is_connected_to_valid_server() noexcept -> bool;

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
}; // class plugin_initializer final

} // namespace plugin

#endif // GADMIN_PLUGIN_PLUGIN_H
