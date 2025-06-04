#ifndef GADMIN_PLUGIN_SAMP_CORE_SERVER_SETTINGS_H
#define GADMIN_PLUGIN_SAMP_CORE_SERVER_SETTINGS_H

#include "plugin/types/address.h"

namespace plugin::samp {

class server_settings final {
private:
    types::dynamic_address<std::uintptr_t> pointer;

    static inline types::offset<float> name_tags_render_distance_offset = 0x27;
    static inline types::offset<bool> name_tags_render_behind_wall_offset = 0x2F;
public:
    auto set_name_tags_render_distance(float distance) const -> void;
    auto set_name_tags_render_behind_wall(bool state) const -> void;

    explicit server_settings(const types::dynamic_address<std::uintptr_t>& pointer)
        : pointer(pointer) {}
}; // class server_settings final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_SERVER_SETTINGS_H
