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

#include "plugin/game/camera.h"
#include "plugin/game/game.h"
#include "plugin/types/address.h"
#include <d3dx9math.h>
#include <cstring>

auto plugin::game::camera::get_fov() noexcept -> float {
    return find_fov_address(*instance_address);
}

auto plugin::game::camera::lerp_fov(float zoom_in_factor, float zoom_out_factor, float time_limit, bool ease)
    noexcept -> void
{
    lerp_fov_address(*instance_address, zoom_in_factor, zoom_out_factor, time_limit, ease);
}

auto plugin::game::camera::get_active_camera() noexcept -> active_camera {
    std::uintptr_t offset = active_camera_index_offset.read(*instance_address) * camera_size;
    return { front_camera_address.read(offset), source_camera_address.read(offset) };
}

auto plugin::game::camera::get_active_coordinates() noexcept -> types::vector_3d {
    return active_camera_coordinates.read();
}

auto plugin::game::camera::get_active_point_at() noexcept -> types::vector_3d {
    active_camera camera = get_active_camera();
    return camera.front + camera.source;
}

auto plugin::game::camera::screen_to_coordinates(float x, float y, float depth)
    noexcept -> types::vector_3d
{
    alignas(16) D3DXMATRIX view_proj_matrix;
    alignas(16) D3DXMATRIX inv_matrix;

    std::memcpy(&view_proj_matrix, reinterpret_cast<char*>(0xB6FA2C), sizeof(D3DXMATRIX));
    std::memset(&inv_matrix, 0, sizeof(D3DXMATRIX));

    view_proj_matrix._44 = 1.0f;

    D3DXMatrixInverse(&inv_matrix, nullptr, &view_proj_matrix);

    auto resolution = plugin::game::get_screen_resolution();
    float recip = 1.0f / depth;
    float screen_x = x / (recip * resolution.first);
    float screen_y = y / (recip * resolution.second);

    return {
        depth * inv_matrix._31 + screen_y * inv_matrix._21 + screen_x * inv_matrix._11 + inv_matrix._41,
        depth * inv_matrix._32 + screen_y * inv_matrix._22 + screen_x * inv_matrix._12 + inv_matrix._42,
        depth * inv_matrix._33 + screen_y * inv_matrix._23 + screen_x * inv_matrix._13 + inv_matrix._43
    };
}
