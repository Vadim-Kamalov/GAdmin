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
/// @file include/plugin/game/camera.h
/// @details Provides functionality for managing in-game camera operations.

#ifndef GADMIN_PLUGIN_GAME_CAMERA_H
#define GADMIN_PLUGIN_GAME_CAMERA_H

#include "plugin/types/simple.h"
#include "plugin/types/address.h"
#include <cstdint>

namespace plugin {
namespace signatures {

/// @brief Function pointer type for linear interpolation of the field of view.
using lerp_fov = void(__thiscall*)(std::uintptr_t, float, float, float, bool);

/// @brief Function pointer type for finding the active camera's FOV.
using find_fov = float(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace game {

/// @class camera
/// @brief Manages in-game camera operations and properties.
class camera final {
private:
    struct active_camera {
        types::vector_3d front;
        types::vector_3d source;
    }; // struct active_camera
    
    static inline types::address<types::vector_3d> active_camera_coordinates = 0xB6F338;
    static inline types::address<std::uintptr_t> instance_address = 0xB6F028;
    static inline types::offset<std::uint8_t> active_camera_index_offset = 0x59;
    static inline types::address<signatures::lerp_fov> lerp_fov_address = 0x50D280;
    static inline types::address<signatures::find_fov> find_fov_address = 0x50AD20;
    static inline types::address<types::vector_3d> front_camera_address = 0xB6F32C;
    static inline types::address<types::vector_3d> source_camera_address = 0xB6F338;

    static auto get_active_camera() noexcept -> active_camera;
public:
    /// @brief Gets the FOV from the active camera.
    /// @return Active camera's FOV.
    static auto get_fov() noexcept -> float;

    /// @brief Linearly interpolates the field of view.
    /// @param zoom_in_factor Factor to zoom in.
    /// @param zoom_out_factor Factor to zoom out.
    /// @param time_limit Time limit for the interpolation.
    /// @param ease Whether to ease the interpolation.
    static auto lerp_fov(float zoom_in_factor, float zoom_out_factor, float time_limit, bool ease) noexcept -> void;
    
    /// @brief Gets the active camera coordinates.
    /// @return The active camera coordinates.
    static auto get_active_coordinates() noexcept -> types::vector_3d;

    /// @brief Gets the point at which the camera is looking.
    /// @return The point at which the camera is looking.
    static auto get_active_point_at() noexcept -> types::vector_3d;

    /// @brief Converts screen coordinates to world coordinates.
    /// @param x The x-coordinate on the screen.
    /// @param y The y-coordinate on the screen.
    /// @param depth The depth on the screen.
    /// @return The corresponding world coordinates.
    static auto screen_to_coordinates(float x, float y, float depth) noexcept -> types::vector_3d;
private:
    static constexpr std::uintptr_t camera_size = 0x238;
}; // class camera final

} // namespace game
} // namespace plugin

#endif // GADMIN_PLUGIN_GAME_CAMERA_H
