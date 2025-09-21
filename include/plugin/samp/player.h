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

#ifndef GADMIN_PLUGIN_SAMP_PLAYER_H
#define GADMIN_PLUGIN_SAMP_PLAYER_H

#include "plugin/samp/core/ped.h"
#include "plugin/types/color.h"
#include <cstdint>
#include <string>
#include <deque>

namespace plugin::samp {

/// Represents a player or an user on the server. Provides
/// common methods for interacting with a player or an user.
class player final {
public:
    using id_t = std::uint16_t;                    ///< Player's ID.
    using nickname_t = std::string;                ///< Player's nickname.
    using stream_entry_t = std::pair<player, ped>; ///< Entry in the current stream.
    using ping_t = int;                            ///< Player's ping.

    static constexpr id_t id_none = 0xFFFF;         ///< None ID.
    static constexpr nickname_t nickname_none = ""; ///< None nickname.
private:
    bool local_player = false, valid = false;
    auto write_local_player(id_t new_id) -> void;
public:
    id_t id = id_none;                   ///< Player's current ID.
    nickname_t nickname = nickname_none; ///< Player's current nickname.
    
    /// Get player's current clist.
    ///
    /// @return Player's clist.
    auto get_color() const -> types::color;
    
    /// Get player's current ping.
    ///
    /// @return Player's current ping.
    auto get_ping() const -> ping_t;
    
    /// Check if a player is on the server.
    ///
    /// @return True if a player is on the server.
    auto is_available() const -> bool;
    
    /// Boolean operator to check if a player is on the server.
    /// Same as `is_available()` but as the operator function.
    explicit operator bool() const;

    /// Get players in the current stream around the user.
    ///
    /// @return Players in the current stream around the user.
    static auto get_stream_players() -> std::deque<stream_entry_t>;
    
    /// Construct player with its ID.
    ///
    /// @note             Must check `is_available()` after construction.
    /// @param new_id[in] Player's ID.
    explicit player(id_t new_id);

    /// Construct player with its nickname.
    ///
    /// @note                   Must check `is_available()` after construction.
    /// @param new_nickname[in] Player's nickname.
    explicit player(const nickname_t& new_nickname);
}; // class player final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_PLAYER_H
