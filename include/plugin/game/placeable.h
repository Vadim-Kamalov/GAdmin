/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2024-2025 The Contributors.
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
/// @file include/plugin/game/placeable.h
/// @details Provides functionality for managing placeable entities in the game.

#ifndef GADMIN_PLUGIN_GAME_PLACEABLE_H
#define GADMIN_PLUGIN_GAME_PLACEABLE_H

#include "plugin/game/entity.h"
#include "plugin/types/address.h"
#include <numbers>

namespace plugin {
namespace signatures {

using get_placeable_rotation = float(__thiscall*)(std::uintptr_t);
using set_placeable_heading = void(__thiscall*)(std::uintptr_t, float);

} // namespace signatures

namespace game {

/// @class placeable
/// @brief Represents a placeable entity in the game.
class placeable : public entity {
public:
    /// @struct physical_flags_t
    /// @brief Contains various physical state flags for the placeable entity
    struct physical_flags_t {
        std::uint8_t : 8;
        std::uint8_t : 5;
        std::uint8_t locked : 1;
        std::uint8_t : 2;
        std::uint8_t soft : 1;
        std::uint8_t : 7;
        std::uint8_t : 8;
    }; // struct physical_flags_t
protected:
    auto set_heading_in_rad(float angle) const -> void;
    auto set_heading_in_deg(float angle) const -> void;
    auto clamp_angle(float angle) const -> float;

    static constexpr float rad_to_deg_multiplier = 180.0f / std::numbers::pi;
    static constexpr float deg_to_rad_multiplier = std::numbers::pi / 180.0f;
private:
    static inline types::address<signatures::get_placeable_rotation> get_placeable_rotation = 0x441DB0;
    static inline types::address<signatures::set_placeable_heading> set_placeable_heading = 0x43E0C0;
    static inline types::offset<physical_flags_t> physical_flags_offset = 0x40;
    static inline types::offset<int> entity_flags_offset = 0x1C;
public:
    virtual ~placeable() = default;
    
    /// @brief Checks if the placeable entity is available.
    /// @return True if the entity is available, false otherwise
    inline auto is_available() const -> bool;

    /// @brief Boolean operator to check if the placeable entity is available.
    /// @return True if the entity is available, false otherwise.
    inline explicit operator bool() const;
    
    /// @brief Checks if the placeable entity is locked.
    /// @return True if the entity is locked, false otherwise.
    auto is_locked() const -> bool;

    /// @brief Sets the lock state of the placeable entity.
    /// @param state The state to set for the entity's lock.
    auto set_lock(bool state) const -> void;

    /// @brief Gets the heading of the placeable entity.
    /// @return The heading of the entity.
    auto get_heading() const -> float;

    /// @brief Sets the heading of the placeable entity.
    /// @param angle The angle of the angle need to be set.
    virtual auto set_heading(float angle) const -> void;

    /// @brief Constructor for the placeable class using the entity constructor.
    using entity::entity;
}; // class placeable

} // namespace game
} // namespace plugin

inline auto plugin::game::placeable::is_available() const -> bool {
    return handle.is_available();
}

inline plugin::game::placeable::operator bool() const {
    return is_available();
}

#endif // GADMIN_PLUGIN_GAME_PLACEABLE_H
