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

#ifndef GADMIN_PLUGIN_SERVER_USER_H
#define GADMIN_PLUGIN_SERVER_USER_H

#include "plugin/samp/events/server_message.h"
#include "plugin/samp/events/dialog.h"
#include <chrono>

namespace plugin::server {

/// Provides methods for interacting with a user on the server side.
class user final {
private:
    inline static bool on_alogin = false;
    inline static bool can_send_command = false;
    inline static std::chrono::steady_clock::time_point last_time_authorized;

    static auto on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool;
    static auto on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool;
public:
    /// Check whether the user is in the `/alogin` state.
    ///
    /// @return True if the user is in the `/alogin` state.
    static inline auto is_on_alogin() noexcept -> bool;

    /// Set the user's `/alogin` state.
    ///
    /// @param state[in] New `/alogin` state for the user.
    static auto set_alogin_state(bool state) -> void;

    /// Main loop for the user handler.
    static auto main_loop() -> void;

    /// Handle SA:MP event for the user handler.
    ///
    /// @param event[in] SA:MP event information.
    /// @return          Whether the event should continue processing.
    static auto on_event(const samp::event_info& event) -> bool;
}; // class user final

} // namespace plugin::server

inline auto plugin::server::user::is_on_alogin() noexcept -> bool {
    return on_alogin;
}

#endif // GADMIN_PLUGIN_SERVER_USER_H
