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
/// @file include/plugin/game/ped_model.h
/// @details Provides constants and functions related to pedestrian models in the game

#ifndef GADMIN_PLUGIN_GAME_PED_MODEL_H
#define GADMIN_PLUGIN_GAME_PED_MODEL_H

#include <cstdint>

namespace plugin::game {

static constexpr float max_male_model_speed = 7;
static constexpr float max_female_model_speed = 5;
static constexpr float special_models_speed[3][2] = { { 0, 11 }, { 92, 8 }, { 99, 8 } };

static constexpr std::uint16_t female_models_index[] = {
    9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 53, 54, 55, 56,
    63, 64, 65, 69, 75, 76, 77, 85, 87, 88, 89, 90, 91, 92,
    93, 129, 130, 131, 138, 139, 140, 141, 145, 148, 150,
    151, 152, 157, 169, 172, 178, 190, 191, 192, 193, 194,
    195, 196, 197, 198, 199, 201, 205, 207, 211, 214, 215,
    216, 218, 219, 224, 225, 226, 231, 232, 233, 237, 238,
    243, 244, 245, 246, 251, 256, 257, 263, 298, 306, 307,
    308, 309
}; // static constexpr std::uint16_t female_models_index[]

/// @brief Gets the maximum speed for a pedestrian model.
/// @param ped_model_index The index of the pedestrian model.
/// @return The maximum speed for the pedestrian model.
constexpr auto get_max_ped_model_speed(std::uint16_t ped_model_index) noexcept -> float;

} // namespace plugin::game

constexpr auto plugin::game::get_max_ped_model_speed(std::uint16_t ped_model_index) noexcept -> float {
    for (const auto& special : special_models_speed)
        if (special[0] == ped_model_index)
            return special[1];

    for (std::uint16_t female_model_index : female_models_index)
        if (female_model_index == ped_model_index)
            return max_female_model_speed;

    return max_male_model_speed;
}

#endif // GADMIN_PLUGIN_GAME_PED_MODEL_H
