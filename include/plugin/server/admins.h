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

#ifndef GADMIN_PLUGIN_SERVER_ADMINS_H
#define GADMIN_PLUGIN_SERVER_ADMINS_H

#include "plugin/samp/events/dialog.h"
#include "plugin/samp/events/server_message.h"
#include "plugin/samp/events/server_quit.h"
#include "plugin/samp/events/set_player_name.h"
#include <nlohmann/detail/macro_scope.hpp>
#include <vector>

namespace plugin::server {

/// Represents an administrator on the server.
struct admin final {
    std::string nickname; ///< Administrator's OOC nickname.
    std::uint16_t id;     ///< Administrator's ID.
    std::uint8_t level;   ///< Administrator's level in the `[1-5]` range.

    /// Options to sort in the container of administrators.
    enum class sort_option {
        disabled, ///< No sorting.
        length,   ///< Sort by `nickname.length()` (lower -> upper).
        id,       ///< Sort by administrators' ID (lower -> upper).
        level     ///< Sort by administrators' level (lower -> upper).
    }; // enum class sort_option;

    /// Sort vector of the administrators.
    ///
    /// @param admins[out] Vector of the administrators.
    /// @param option[in]  Sort option.
    static auto sort(std::vector<admin>& admins, const sort_option& option) -> void;
}; // struct admin final

/// Represents the administrators' handler: handles connections
/// and disconnections providing actual administrators' list.
class admins final {
private:
    static auto on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool;
    static auto on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool;
    static auto on_server_quit(const samp::event<samp::event_id::server_quit>& disconnected) -> bool;
    static auto on_set_player_name(const samp::event<samp::event_id::set_player_name>& player) -> bool;

    static auto update_admins(const std::string_view& dialog_text) -> void;
    static auto add_connected_admin(const admin& connected_admin) -> void;
    static auto remove_disconnected_admin(std::uint16_t id) -> void;
public:
    /// Current connected (and logged-in) administrators' on the server.
    inline static std::vector<admin> list;

    /// Find admin by his ID.
    ///
    /// @param id[in] Administrator's ID.
    /// @return       `admin` if found, `std::nullopt` othwerwise.
    static auto get_admin(std::uint16_t id) -> std::optional<admin>;

    /// Send information to the handler that user sent `/alogout` command.
    static auto on_alogout() -> void;

    /// Send information to the handler about the SA:MP event.
    ///
    /// @param info[in] SA:MP event information.
    /// @reutrn         Whether the event should continue processing.
    static auto on_event(const samp::event_info& info) -> bool;
}; // class admins final

NLOHMANN_JSON_SERIALIZE_ENUM(admin::sort_option, {
    { admin::sort_option::disabled, "disabled" },
    { admin::sort_option::length, "length" },
    { admin::sort_option::id, "id" },
    { admin::sort_option::level, "level" }
})

} // namespace plugin::server

#endif // GADMIN_PLUGIN_SERVER_ADMINS_H
