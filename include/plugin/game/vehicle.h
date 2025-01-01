#ifndef GADMIN_PLUGIN_GAME_VEHICLE_H
#define GADMIN_PLUGIN_GAME_VEHICLE_H

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

constexpr std::uint16_t get_max_vehicle_model_speed(std::uint16_t vehicle_model_index) noexcept;

} // namespace plugin::game

constexpr std::uint16_t
plugin::game::get_max_vehicle_model_speed(std::uint16_t vehicle_model_index) noexcept {
    return max_vehicle_speeds[vehicle_model_index - min_vehicle_id];
}

#endif // GADMIN_PLUGIN_GAME_VEHICLE_H
