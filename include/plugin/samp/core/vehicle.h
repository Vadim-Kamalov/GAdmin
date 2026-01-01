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

#ifndef GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H
#define GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H

#include "plugin/game/vehicle.h"
#include "plugin/samp/core/entity.h"
#include "plugin/types/address.h"

namespace plugin::samp {

/// Represents a vehicle created by the SA:MP client.
class vehicle final : public entity {
private:
    static inline types::offset<int> engine_active_offset = 0x50;
    static inline types::offset<int> locked_offset = 0x60;
    static inline types::offset<game::vehicle> game_vehicle_offset = 0x4C;
public:
    /// Get original vehicle from the game.
    ///
    /// @return Original vehicle from the game.
    auto get_game_vehicle() const -> game::vehicle;
    
    /// Check if the vehicle's engine active.
    ///
    /// @return True if the vehicle's engine is active.
    auto is_engine_active() const -> bool;

    /// Check if the vehicle is locked.
    ///
    /// @return True if the vehicle is locked.
    auto is_locked() const -> bool;

    using entity::entity;
}; // class vehicle final : public entity

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H
