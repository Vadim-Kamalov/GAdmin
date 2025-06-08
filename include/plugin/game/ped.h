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
///
/// @file include/plugin/game/ped.h
/// @details Provides functionality for managing in-game pedestrian entities.

#ifndef GADMIN_PLUGIN_GAME_PED_H
#define GADMIN_PLUGIN_GAME_PED_H

#include "plugin/game/placeable.h"
#include "plugin/game/vehicle.h"
#include "plugin/game/weapon.h"
#include "plugin/types/address.h"
#include "plugin/types/simple.h"

namespace plugin {
namespace signatures {

using teleport = void(__thiscall*)(std::uintptr_t, types::vector_3d, bool);
using get_bone_position = void(__thiscall*)(std::uintptr_t, types::vector_3d*, int, bool);
using task_process_ped = bool(__thiscall*)(std::uintptr_t, std::uintptr_t);

} // namespace signatures

namespace game {

/// @class ped
/// @brief Represents a pedestrian entity in the game.
class ped final : public placeable {
public:
    /// @struct flags_t
    /// @brief Contains various state flags for the pedestrian.
    struct flags_t {
        std::uint8_t is_standing : 1;
        std::uint8_t was_standing : 1;
        std::uint8_t : 6;
        std::uint8_t in_vehicle : 1;
        std::uint8_t in_the_air : 1;
    }; // struct flags_t

    /// @enum bone
    /// @brief Enumeration of bone identifiers.
    enum bone { head = 6 };
private:
    static inline types::address<signatures::teleport> teleport_address = 0x5E4110;
    static inline types::address<signatures::get_bone_position> get_bone_position_address = 0x5E4280;
    static inline types::address<ped> player_address = 0xB6F5F0;
    static inline types::offset<vehicle> vehicle_offset = 0x58C;
    static inline types::offset<float> current_rotation_offset = 0x558;
    static inline types::offset<float> aiming_rotation_offset = 0x55C;
    static inline types::offset<types::vector_3d> speed_offset = 0x44;
    static inline types::offset<flags_t> flags_offset = 0x46C;
    static inline types::offset<std::uint8_t> target_state_offset = 0x528;
    static inline types::offset<std::uintptr_t> weapons_offset = 0x5A0;
    static inline types::offset<std::uint8_t> current_weapon_slot_offset = 0x718;
public:
    /// @brief Checks if the pedestrian is in the air.
    /// @return True if the pedestrian is in the air, false otherwise
    auto is_in_the_air() const -> bool;

    /// @brief Checks if the pedestrian is targeting.
    /// @return True if the pedestrian is targeting, false otherwise.
    auto is_targeting() const -> bool;

    /// @brief Gets the speed of the pedestrian.
    /// @return The speed of the pedestrian.
    auto get_speed() const -> types::meter_per_second_t;

    /// @brief Gets the position of a specific bone of the pedestrian.
    /// @param bone_id The bone identifier.
    /// @return The position of the specified bone.
    auto get_bone_bosition(const bone& bone_id) const -> types::vector_3d;

    /// @brief Gets the current weapon of the pedestrian.
    /// @return The current weapon.
    auto get_current_weapon() const -> weapon;

    /// @brief Gets the vehicle the pedestrian is in.
    /// @return The vehicle the pedestrian is in.
    auto get_vehicle() const -> vehicle;

    /// @brief Gets the player pedestrian.
    /// @return The player pedestrian.
    static auto get_player() noexcept -> ped;
    
    /// @brief Makes the pedestrian jump into a vehicle.
    /// @note The pedestrian always jumps as driver.
    /// @param vehicle The vehicle to jump into.
    auto jump_into_vehicle(const vehicle& vehicle) const -> void;

    /// @brief Teleports the pedestrian to a new position.
    /// @param pos The new position to teleport to.
    auto teleport(const types::vector_3d& pos) const -> void override;

    /// @brief Sets the heading of the pedestrian.
    /// @param angle The angle to set the heading to.
    auto set_heading(float angle) const -> void override;

    using placeable::placeable;
private:
    static constexpr std::ptrdiff_t weapon_size = 0x1C;
}; // class ped final : public placeable

} // namespace game
} // namespace plugin

#endif // GADMIN_PLUGIN_GAME_PED_H
