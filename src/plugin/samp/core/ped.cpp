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

#include "plugin/samp/core/ped.h"

plugin::types::versioned_address_container<plugin::signatures::get_current_weapon_t>
plugin::samp::ped::get_current_weapon_container = { 0xA6510, 0xAB3C0, 0xABC50, 0xAB870 };

auto plugin::samp::ped::get_game_ped() const -> game::ped {
    return game_ped.read(*handle);
}

auto plugin::samp::ped::get_current_weapon() const -> game::weapon {
    return static_cast<game::weapon>(get_current_weapon_container->invoke(*handle));
}
