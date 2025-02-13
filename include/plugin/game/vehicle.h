#ifndef GADMIN_PLUGIN_GAME_VEHICLE_H
#define GADMIN_PLUGIN_GAME_VEHICLE_H

#include "plugin/types/simple.h"
#include <cstdint>

namespace plugin::game {

static constexpr std::uint16_t min_vehicle_id = 400;
static constexpr std::uint16_t max_vehicle_id = 611;
static constexpr std::uint16_t vehicle_count = max_vehicle_id - min_vehicle_id;

static constexpr std::uint16_t max_vehicle_speeds[vehicle_count + 1] = {
    88, 81, 103, 61, 74, 91, 61, 82, 55, 88, 72, 123,
    93, 61, 59, 107, 85, 61, 64, 83, 81, 85, 78, 55,
    75, 110, 96, 65, 65, 112, 104, 72, 52, 61, 93, 0,
    83, 88, 79, 93, 76, 0, 77, 70, 62, 91, 130, 71,
    62, 0, 0, 107, 102, 33, 74, 88, 59, 53, 87, 76,
    98, 89, 62, 80, 0, 0, 82, 78, 80, 70, 87, 61, 73,
    60, 83, 96, 140, 103, 65, 78, 102, 50, 87, 68, 37,
    55, 36, 96, 82, 77, 87, 83, 78, 99, 119, 98, 90, 98,
    60, 68, 78, 0, 119, 119, 96, 77, 99, 92, 60, 43, 55,
    81, 73, 91, 67, 79, 87, 87, 91, 150, 150, 89, 98, 84,
    72, 89, 87, 83, 98, 83, 34, 39, 61, 93, 93, 87, 96, 0,
    0, 55, 83, 113, 91, 84, 82, 81, 83, 79, 75, 85, 80, 87,
    67, 130, 80, 88, 61, 61, 87, 99, 94, 85, 99, 80, 0, 91,
    89, 96, 81, 0, 0, 52, 61, 61, 33, 87, 87, 150, 72, 87,
    85, 94, 76, 47, 0, 85, 80, 91, 60, 90, 0, 0, 150, 105,
    0, 65, 98, 98, 98, 89, 84, 61, 94, 95, 82, 84, 0, 0, 0,
    60, 0, 0
}; // static constexpr std::uint16_t max_vehicle_speeds[]

static constexpr types::zstring_t vehicle_names[vehicle_count + 1] = {
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perennial", "Sentinel",
    "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
    "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Mr. Whoopee", "BF Injection",
    "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
    "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
    "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral",
    "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
    "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van",
    "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale",
    "Oceanic", "Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes",
    "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper",
    "Marquis", "Baggage", "Dozer", "Maverick", "SAN News Maverick", "Rancher", "FBI Rancher",
    "Virgo", "Greenwood", "Jetmax", "Hotring Racer", "Sandking", "Blista Compact", "Police Maverick",
    "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer", "Hotring Racer", "Bloodring Banger",
    "Rancher", "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stuntplane",
    "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000",
    "Cement Truck", "Towtruck", "Fortune", "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor",
    "Combine Harvester", "Feltzer", "Remington", "Slamvan", "Blade", "Freight", "Brown Streak", "Vortex", "Vincent",
    "Bullet", "Clover", "Sadler", "Firetruck LA", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise",
    "Merit", "Utility Van", "Nevada", "Yosemite", "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan",
    "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito", "Freight", "Brown Streak",
    "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
    "Newsvan", "Tug", "Petrol Truck", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club", "Freight Box", "Trailer",
    "Andromada", "Dodo", "RC Cam", "Launch", "Police Car (LSPD)", "Police Car (SFPD)", "Police Car (LVPD)", "Ranger",
    "Picador", "S.W.A.T.", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage A", "Luggage B", "Stairs", "Boxville",
    "Tiller", "Utility Trailer"
}; // static constexpr types::zstring_t vehicle_names[vehicle_count + 1]

constexpr std::uint16_t get_max_vehicle_model_speed(std::uint16_t vehicle_model_index) noexcept;
constexpr types::zstring_t get_vehicle_name(std::uint16_t vehicle_model_index) noexcept;

} // namespace plugin::game

constexpr std::uint16_t
plugin::game::get_max_vehicle_model_speed(std::uint16_t vehicle_model_index) noexcept {
    return max_vehicle_speeds[vehicle_model_index - min_vehicle_id];
}

constexpr plugin::types::zstring_t
plugin::game::get_vehicle_name(std::uint16_t vehicle_model_index) noexcept {
    return vehicle_names[vehicle_model_index - min_vehicle_id];
}

#endif // GADMIN_PLUGIN_GAME_VEHICLE_H
