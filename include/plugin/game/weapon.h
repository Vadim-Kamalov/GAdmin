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
/// @file include/plugin/game/weapon.h
/// @details Provides enumerations and constants related to weapons in the game

#ifndef GADMIN_PLUGIN_GAME_WEAPON_H
#define GADMIN_PLUGIN_GAME_WEAPON_H

#include "plugin/types/simple.h"
#include <utility>

namespace plugin::game {

/// @enum weapon
/// @brief Enumeration of weapon types.
enum class weapon : char {
    fist, brass_knuckles, golf_club, night_stick, knife,
    baseball_bat, shovel, pool_cue, katana, chainsaw,
    purple_dildo, white_dildo, white_vibrator,
    silver_vibrator, flowers, cane, grenade, tear_gas,
    molotov, colt45 = 22, silenced_pistol, desert_eagle,
    shotgun, sawnoff_shotgun, combat_shotgun, uzi, mp5,
    ak47, m4, tec9, rifle, sniper_rifle, rocket_launcher,
    heat_seeker, flame_thrower, minigun, satchelcharge,
    detonator, spraycan, fire_extinguisher, camera,
    night_vision, thermal_vision, parachute
}; // enum class weapon

/// @brief Names of weapon types.
static constexpr types::zstring_t weapon_names[std::to_underlying(weapon::parachute) + 1] = {
	"Fist", "Brass Knuckles", "Golf Club", "Nightstick", "Knife", "Baseball Bat",
	"Shovel", "Pool Cue", "Katana", "Chainsaw", "Purple Dildo", "Dildo", "Vibrator",
	"Silver Vibrator", "Flowers", "Cane", "Grenade", "Tear Gas", "Molotov Cocktail",
	"", "", "", "9mm", "Silenced 9mm", "Desert Eagle", "Shotgun", "Sawnoff Shotgun",
	"Combat Shotgun", "Micro Uzi", "MP5", "AK-47", "M4", "Tec-9", "Country Rifle",
    "Sniper Rifle", "RPG", "HS Rocket", "Flamethrower", "Minigun", "Satchel Charge",
	"Detonator", "Spraycan", "Fire Extinguisher", "Camera", "Night Vis Goggles",
	"Thermal Goggles", "Parachute"
}; // static constexpr types::zstring_t weapon_names[std::to_underlying(weapon::parachute) + 1]

} // namespace plugin::game

template<>
struct std::formatter<plugin::game::weapon> : std::formatter<std::string_view> {
    auto format(const plugin::game::weapon& weapon, std::format_context& ctx) const {
        return std::format_to(ctx.out(), "{}", plugin::game::weapon_names[std::to_underlying(weapon)]);
    }
}; // struct std::formatter<plugin::server::spectator::platform_t> : std::formatter<std::string_view>

#endif // GADMIN_PLUGIN_GAME_UTILS_H
