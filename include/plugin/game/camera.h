#ifndef GADMIN_PLUGIN_GAME_CAMERA_H
#define GADMIN_PLUGIN_GAME_CAMERA_H

#include "plugin/types/simple.h"
#include "plugin/types/address.h"
#include <cstdint>

namespace plugin {
namespace signatures {

using lerp_fov = void(__thiscall*)(std::uintptr_t, float, float, float, bool);

} // namespace signatures

namespace game {

class camera {
private:
    struct active_camera {
        types::vector_3d front;
        types::vector_3d source;
    }; // struct active_camera

    static inline types::address<types::vector_3d> active_camera_coordinates = 0xB6F338;
    static inline types::address<std::uintptr_t> instance_address = 0xB6F028;
    static inline types::offset<std::uint8_t> active_camera_index_offset = 0x59;
    static inline types::address<signatures::lerp_fov> lerp_fov_address = 0x50D280;
    static inline types::address<types::vector_3d> front_camera_address = 0xB6F32C;
    static inline types::address<types::vector_3d> source_camera_address = 0xB6F338;

    static active_camera get_active_camera() noexcept;
public:
    static void lerp_fov(float zoom_in_factor, float zoom_out_factor, float time_limit, bool ease) noexcept;
    static types::vector_3d get_active_coordinates() noexcept;
    static types::vector_3d get_active_point_at() noexcept;
    static types::vector_3d screen_to_coordinates(float x, float y, float depth) noexcept;
private:
    static constexpr std::uintptr_t camera_size = 0x238;
}; // class camera

} // namespace game
} // namespace plugin

#endif // GADMIN_PLUGIN_GAME_CAMERA_H
