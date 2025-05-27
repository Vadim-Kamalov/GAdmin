#include "plugin/game/camera.h"
#include "plugin/game/game.h"
#include "plugin/types/address.h"
#include <d3dx9math.h>
#include <cstring>

void
plugin::game::camera::lerp_fov(float zoom_in_factor, float zoom_out_factor, float time_limit, bool ease) noexcept {
    lerp_fov_address(*instance_address, zoom_in_factor, zoom_out_factor, time_limit, ease);
}

plugin::game::camera::active_camera
plugin::game::camera::get_active_camera() noexcept {
    std::uintptr_t offset = active_camera_index_offset.read(*instance_address) * camera_size;
    return { front_camera_address.read(offset), source_camera_address.read(offset) };
}

plugin::types::vector_3d
plugin::game::camera::get_active_coordinates() noexcept {
    return active_camera_coordinates.read();
}

plugin::types::vector_3d
plugin::game::camera::get_active_point_at() noexcept {
    active_camera camera = get_active_camera();
    return camera.front + camera.source;
}

plugin::types::vector_3d
plugin::game::camera::screen_to_coordinates(float x, float y, float depth) noexcept {
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
