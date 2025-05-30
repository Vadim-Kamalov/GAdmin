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

/// @file include/plugin/game/enity.h
/// @details Provides functionality for managing in-game entities.


#ifndef GADMIN_PLUGIN_GAME_ENTITY_H
#define GADMIN_PLUGIN_GAME_ENTITY_H

#include "plugin/types/address.h"
#include "plugin/types/simple.h"

namespace plugin {
namespace signatures {

    /// @brief Function pointer type for checking if a vehicle pointer is valid.
using is_vehicle_pointer_valid = bool(__stdcall*)(std::uintptr_t);

    /// @brief Function pointer type for checking if an entity is on screen.
using is_on_screen = bool(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace game {

class vehicle;

    /// @class entity
    /// @brief Represents an in-game entity with various properties and methods.
class entity {
public:
    types::dynamic_address<std::uintptr_t> handle;
protected:

    /// @brief Sets the coordinates of the entity.
    /// @param pos The new coordinates to set.

    void set_coordinates(const types::vector_3d& pos) const;
private:
    static inline types::address<signatures::is_vehicle_pointer_valid> is_vehicle_pointer_valid_address = 0x6E38F0;
    static inline types::address<signatures::is_on_screen> is_on_screen_address = 0x534540;
    static inline types::offset<std::uintptr_t> matrix_offset = 0x14;
    static inline types::offset<std::uint16_t> model_index_offset = 0x22;
    static inline types::offset<types::vector_3d> position_offset_in_matrix = 0x30;
public:
    /// @brief Virtual destructor for the entity class
    virtual ~entity() = default;

    /// @brief Checks if the entity is available.
    /// @return True if the entity is available, false otherwise.
    inline bool is_available() const;

    /// @brief Checks if the entity is on screen.
    /// @return True if the entity is on screen, false otherwise.   
    bool is_on_screen() const;

    /// @brief Gets the model index of the entity.
    /// @return The model index.  
    std::uint16_t get_model_index() const;

    /// @brief Gets the position of the entity.
    /// @return The position of the entity.

    types::vector_3d get_position() const;

    /// @brief Gets the vehicle associated with the entity.
    /// @return The vehicle associated with the entity.
    vehicle get_vehicle() const;

    /// @brief Equality operator to compare two entities.
    /// @param other The other entity to compare with.
    /// @return True if the entities are equal, false otherwise. 
    bool operator==(const entity& other) const;

    /// @brief Boolean operator to check if the entity is available.
    /// @return True if the entity is available, false otherwise.
    inline explicit operator bool() const;

    /// @brief Teleports the entity to a new position.
    /// @param pos The new position to teleport to.
    virtual void teleport(const types::vector_3d& pos) const;

    /// @brief Constructor for the entity class.
    /// @param handle The dynamic address handle for the entity.
    explicit entity(const types::dynamic_address<std::uintptr_t>& handle)
        : handle(handle) {}
}; // class entity

} // namespace game
} // namespace plugin

inline bool
plugin::game::entity::is_available() const {
    return handle.is_available();
}

/// @brief Boolean operator to check if the entity is available.
/// @return True if the entity is available, false otherwise.
inline plugin::game::entity::operator bool() const {
    return is_available();
}

#endif // GADMIN_PLUGIN_GAME_ENTITY_H
