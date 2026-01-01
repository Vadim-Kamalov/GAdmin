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

#ifndef GADMIN_PLUGIN_SAMP_CORE_PED_H
#define GADMIN_PLUGIN_SAMP_CORE_PED_H

#include "plugin/game/ped.h"
#include "plugin/game/weapon.h"
#include "plugin/samp/core/entity.h"

namespace plugin {
namespace signatures {

using get_current_weapon_t = char(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

/// Represents a ped created by the SA:MP client.
class ped final : public entity {
private:
    static inline types::offset<game::ped> game_ped = 0x2A4;
    static types::versioned_address_container<signatures::get_current_weapon_t> get_current_weapon_container;
public:
    /// Get original ped from the game.
    ///
    /// @return Original ped from the game.
    auto get_game_ped() const -> game::ped;
    
    /// Get current weapon of the ped.
    ///
    /// @return Current weapon of the ped.
    auto get_current_weapon() const -> game::weapon;

    using entity::entity;
}; // class ped final : public entity

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_PED_H
