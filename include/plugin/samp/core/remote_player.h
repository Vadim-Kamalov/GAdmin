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

#ifndef GADMIN_PLUGIN_SAMP_CORE_REMOTE_PLAYER_H
#define GADMIN_PLUGIN_SAMP_CORE_REMOTE_PLAYER_H

#include "plugin/samp/core/ped.h"
#include "plugin/samp/core/vehicle.h"
#include "plugin/types/address.h"
#include "plugin/types/color.h"
#include "plugin/types/signatures.h"

namespace plugin {
namespace signatures {

using get_color_as_argb = types::signatures::thiscall_t<std::uint32_t, std::uintptr_t>;

} // namespace signatures

namespace samp {

/// Represents remote player in the SA:MP client.
class remote_player final {
public:
    /// Remote player connection state.
    enum class state : int {
        paused = 2,  ///< Remote player is currently in the pause mode (AFK).
        onfoot = 17, ///< Remote player is currently onfoot.
        passenger,   ///< Remote player is currently a passenger.
        driver = 19, ///< Remote player is currently a driver.
        wasted = 32, ///< Remote player is recently died.
        spawned      ///< Remote player is recently spawned.
    }; // enum class state : int
private:
    types::dynamic_address<std::uintptr_t> handle = 0;

    static types::versioned_address_container<ped, types::version_container_option::offsets> ped_container;
    static types::versioned_address_container<vehicle, types::version_container_option::offsets> vehicle_container;
    static types::versioned_address_container<float, types::version_container_option::offsets> armor_container;
    static types::versioned_address_container<signatures::get_color_as_argb> get_color_container;
    static types::versioned_address_container<std::uint16_t, types::version_container_option::offsets> id_container;
    static types::versioned_address_container<int, types::version_container_option::offsets> state_container;
public:
    /// Check if the remote player's pointer is not null. Equivalent to `handle.is_available()`.
    ///
    /// @return True if the remote player's pointer is not null.
    auto is_available() const -> bool;

    /// Extract ped of the SA:MP client from remote player structure.
    ///
    /// @return Ped of the SA:MP client.
    auto get_ped() const -> ped;
    
    /// Extract vehicle of the SA:MP client from remote player structure.
    ///
    /// @return Vehicle of the SA:MP client.
    auto get_vehicle() const -> vehicle;
    
    /// Get remote player's armor.
    ///
    /// @return Remote player's armor.
    auto get_armor() const -> float;

    /// Get remote player's clist color.
    ///
    /// @return Remote player's clist color.
    auto get_color() const -> types::color;

    /// Get remote player's ID.
    ///
    /// @return Remote player's ID.
    auto get_id() const -> std::uint16_t;

    /// Check if remote player's current and passed states are equal.
    ///
    /// @return True if current and passed state of remote player are equal.
    auto is_current_state(const remote_player::state& state) const -> bool;

    /// Construct remote player class.
    /// 
    /// @param handle[in] Dynamic address handle for the remote player.
    explicit remote_player(const types::dynamic_address<std::uintptr_t>& handle)
        : handle(handle) {}

    remote_player() = default;
}; // class remote_player final

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_REMOTE_PLAYER_H
