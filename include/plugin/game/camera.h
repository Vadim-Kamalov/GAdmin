#ifndef GADMIN_PLUGIN_GAME_CAMERA_H
#define GADMIN_PLUGIN_GAME_CAMERA_H

#include "plugin/types/simple.h"
#include "plugin/types/address.h"
#include <cstdint>

namespace plugin::game {

class camera {
private:
    struct active_camera {
        types::vector_3d front;
        types::vector_3d source;
    }; // struct active_camera

    static inline types::address<types::vector_3d> active_camera_coordinates = 0xB6F338;
    static inline types::address<std::uintptr_t> instance_address = 0xB6F028;
    static inline types::offset<std::uint8_t> active_camera_index_offset = 0x59;
    static inline types::address<types::vector_3d> front_camera_address = 0xB6F32C;
    static inline types::address<types::vector_3d> source_camera_address = 0xB6F338;

    static active_camera get_active_camera() noexcept;
public:
    static types::vector_3d get_active_coordinates() noexcept;
    static types::vector_3d get_active_point_at() noexcept;
private:
    static constexpr std::uintptr_t camera_size = 0x238;
}; // class camera

} // namespace plugin::game

#endif // GADMIN_PLUGIN_GAME_CAMERA_H
