#include "plugin/game/camera.h"

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
