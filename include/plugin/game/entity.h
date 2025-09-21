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

#ifndef GADMIN_PLUGIN_GAME_ENTITY_H
#define GADMIN_PLUGIN_GAME_ENTITY_H

#include "plugin/types/address.h"
#include "plugin/types/simple.h"

namespace plugin {
namespace signatures {

using is_vehicle_pointer_valid = bool(__stdcall*)(std::uintptr_t);
using is_on_screen = bool(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace game {

class vehicle;

/// Base class of `game::placeable`. Represents an in-game entity and its methods.
class entity {
public:
    /// Entity handle.
    types::dynamic_address<std::uintptr_t> handle;
protected:
    /// Set the coordinates for the entity.
    /// 
    /// @param pos[in] New coordinates to set.
    void set_coordinates(const types::vector_3d& pos) const;
private:
    static inline types::address<signatures::is_vehicle_pointer_valid> is_vehicle_pointer_valid_address = 0x6E38F0;
    static inline types::address<signatures::is_on_screen> is_on_screen_address = 0x534540;
    static inline types::offset<std::uintptr_t> matrix_offset = 0x14;
    static inline types::offset<std::uint16_t> model_index_offset = 0x22;
    static inline types::offset<types::vector_3d> position_offset_in_matrix = 0x30;
public:
    virtual ~entity() = default;

    /// Check if an entity pointer is not null. Equivalent to `handle.is_available()`.
    ///
    /// @return True if the entity pointer is not null.
    inline auto is_available() const -> bool;

    /// Check if an entity is on screen.
    /// 
    /// @return True if the entity is on screen.
    auto is_on_screen() const -> bool;

    /// Get the model index of an entity.
    ///
    /// @return Model index (range: 400–611).
    auto get_model_index() const -> std::uint16_t;

    /// Get the position of an entity.
    /// 
    /// @return Position of the entity.
    auto get_position() const -> types::vector_3d;

    /// Get the vehicle associated with an entity.
    /// 
    /// @return Vehicle associated with the entity.
    auto get_vehicle() const -> vehicle;

    /// Check the equality of two entities. Equivalent to `handle == other.handle`.
    ///
    /// @param other[in] Entity to compare with.
    /// @return          True if the entity pointers are equal.
    auto operator==(const entity& other) const -> bool;

    /// Boolean operator to check if an entity is available.
    ///
    /// @return True if the entity pointer is not null.
    inline explicit operator bool() const;

    /// Teleport an entity to a new position.
    /// 
    /// @param pos[in] New position to teleport to.
    virtual auto teleport(const types::vector_3d& pos) const -> void;

    /// Construct entity class.
    /// 
    /// @param handle[in] Dynamic address handle for the entity.
    explicit entity(const types::dynamic_address<std::uintptr_t>& handle)
        : handle(handle) {}
}; // class entity

} // namespace game
} // namespace plugin

inline auto plugin::game::entity::is_available() const -> bool {
    return handle.is_available();
}

inline plugin::game::entity::operator bool() const {
    return is_available();
}

#endif // GADMIN_PLUGIN_GAME_ENTITY_H
