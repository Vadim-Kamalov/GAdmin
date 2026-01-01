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

#ifndef GADMIN_PLUGIN_SAMP_CORE_PLAYER_POOL_H
#define GADMIN_PLUGIN_SAMP_CORE_PLAYER_POOL_H

#include "plugin/samp/core/remote_player.h"
#include "plugin/types/address.h"
#include "plugin/types/simple.h"
#include <cstdint>
#include <string>
#include <expected>

namespace plugin {
namespace signatures {

using get_player_pool_t = std::uintptr_t(__thiscall*)(std::uintptr_t);
using get_nickname_t = types::zstring_t(__thiscall*)(std::uintptr_t, std::uint16_t);
using get_remote_player_t = std::uintptr_t(__thiscall*)(std::uintptr_t, std::uint16_t);
using is_connected_t = bool(__thiscall*)(std::uintptr_t, std::uint16_t);
using get_ping_t = std::int32_t(__thiscall*)(std::uintptr_t, std::uint16_t);

} // namespace signatures

namespace samp {

/// Provides methods for managing and searching in the SA:MP player pool.
class player_pool final {
private:
    static types::versioned_address_container<signatures::get_player_pool_t> get_player_pool_container;
    static types::versioned_address_container<signatures::get_nickname_t> get_nickname_container;
    static types::versioned_address_container<signatures::get_ping_t> get_ping_container;
    static inline types::offset<signatures::get_remote_player_t> get_remote_player_offset = 0x10F0;
    static inline types::offset<signatures::get_remote_player_t> is_connected_offset = 0x10B0;
public:
    /// Possible error codes received from the methods in this class.
    enum class error : std::uint8_t {
        player_not_connected, ///< Player to find is not connected.
        player_not_found      ///< Player not found.
    }; // enum class error : std::uint8_t
  
    /// Get address to the SA:MP player pool instance.
    ///
    /// @return Address to the SA:MP player pool instance.
    static auto instance() noexcept -> std::uintptr_t;

    /// Get player's nickname from its ID.
    ///
    /// @param id[in] Player's ID.
    /// @return       Player's nickname if found, `player_pool::error` otherwise.
    static auto get_nickname(std::uint16_t id) noexcept -> std::expected<std::string, error>;

    /// Get player's ID from its nickname.
    ///
    /// @param nickname[in] Player's nickname.
    /// @return             Player's ID if found, `player_pool::error` otherwise.
    static auto get_id(const std::string_view& nickname) noexcept -> std::expected<std::uint16_t, error>;

    /// Get remote player from the SA:MP client by its id.
    ///
    /// @param id[in]               Player's id.
    /// @param check_connection[in] Whether to need ensure player connection.
    /// @return                     Remote player from the SA:MP client, `player_pool::error` otherwise.
    static auto get_remote_player(std::uint16_t id, bool check_connection = true) noexcept -> std::expected<remote_player, error>;

    /// Get remote player from the SA:MP client by its nickname.
    ///
    /// @param id[in] Player's nickname.
    /// @return       Remote player from the SA:MP client, `player_pool::error` otherwise.
    static auto get_remote_player(const std::string_view& nickname) noexcept -> std::expected<remote_player, error>;

    /// Get player's ping by its id.
    ///
    /// @param id[in] Player's id.
    /// @return       Player's ping if found, `player_pool::error` otherwise.
    static auto get_ping(std::uint16_t id) noexcept -> std::expected<std::int32_t, error>;

    /// Check if player is connected to the server.
    ///
    /// @param id[in] Player's ID.
    /// @return       True if the player is connected to the server.
    static auto is_connected(std::uint16_t id) noexcept -> bool;
}; // class player_pool final

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_PLAYER_POOL_H
