#ifndef GADMIN_PLUGIN_SAMP_CORE_3D_TEXT_H
#define GADMIN_PLUGIN_SAMP_CORE_3D_TEXT_H

#include "plugin/samp/network/bit_stream.h"

namespace plugin::samp {

class creator_3d_text {
public:
    static constexpr std::uint8_t event_id = 36;
    
    std::uint16_t id;
    std::int32_t color;
    float pos_x, pos_y, pos_z;
    float draw_distance;
    std::uint8_t test_los;
    std::uint16_t attached_player_id, attached_vehicle_id;
    std::string text;

    explicit creator_3d_text(samp::bit_stream* stream);
}; // class creator_3d_text

class remover_3d_text {
public:
    static constexpr std::uint8_t event_id = 58;

    std::uint16_t id;

    explicit remover_3d_text(samp::bit_stream* stream);
}; // class remover_3d_text

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_3D_TEXT_H
