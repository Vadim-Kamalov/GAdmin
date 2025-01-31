#ifndef GADMIN_PLUGIN_GAME_WEAPON_H
#define GADMIN_PLUGIN_GAME_WEAPON_H

#include "plugin/utils.h"
#include <utility>

namespace plugin::game {

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

static constexpr utils::zstring_t weapon_names[std::to_underlying(weapon::parachute) + 1] = {
	"Fist", "Brass Knuckles", "Golf Club", "Nightstick", "Knife", "Baseball Bat",
	"Shovel", "Pool Cue", "Katana", "Chainsaw", "Purple Dildo", "Dildo", "Vibrator",
	"Silver Vibrator", "Flowers", "Cane", "Grenade", "Tear Gas", "Molotov Cocktail",
	"", "", "", "9mm", "Silenced 9mm", "Desert Eagle", "Shotgun", "Sawnoff Shotgun",
	"Combat Shotgun", "Micro Uzi", "MP5", "AK-47", "M4", "Tec-9", "Country Rifle",
    "Sniper Rifle", "RPG", "HS Rocket", "Flamethrower", "Minigun", "Satchel Charge",
	"Detonator", "Spraycan", "Fire Extinguisher", "Camera", "Night Vis Goggles",
	"Thermal Goggles", "Parachute"
}; // static constexpr utils::zstring_t weapon_names[std::to_underlying(weapon::parachute) + 1]

} // namespace plugin::game

#endif // GADMIN_PLUGIN_GAME_UTILS_H
