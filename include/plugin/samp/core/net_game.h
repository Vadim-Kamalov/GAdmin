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

#ifndef GADMIN_PLUGIN_SAMP_CORE_NET_GAME_H
#define GADMIN_PLUGIN_SAMP_CORE_NET_GAME_H

#include "plugin/samp/core/server_settings.h"
#include "plugin/types/address.h"
#include "plugin/types/simple.h"
#include <cstdint>

namespace plugin {
namespace signatures {

using update_players_t = void(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

/// Provides methods for operating with SA:MP network interface.
class net_game final {
private:
    static types::versioned_address_container<types::zstring_t, types::version_container_option::offsets> host_address_offsets;
    static types::versioned_address_container<server_settings, types::version_container_option::offsets> server_settings_container;
    static types::versioned_address_container<signatures::update_players_t> update_players_container;
public:
    /// Instance container of the SA:MP network class.
    static types::versioned_address_container<std::uintptr_t> instance_container;

    /// Get current server's settings.
    ///
    /// @return Current server's settings.
    static auto get_server_settings() noexcept -> server_settings;
    
    /// Get current server's host address.
    ///
    /// @return Current server's host address.
    static auto get_host_address() noexcept -> std::string;
    
    /// Update current players in the server.
    static auto update_players() noexcept -> void;
}; // class net_game final

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_NET_GAME_H
