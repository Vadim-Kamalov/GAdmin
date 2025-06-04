#ifndef GADMIN_PLUGIN_SAMP_EVENTS_3D_TEXT_H
#define GADMIN_PLUGIN_SAMP_EVENTS_3D_TEXT_H

#include "plugin/samp/events/event.h"
#include "plugin/types/simple.h"

namespace plugin::samp {

template<>
struct event<event_id::create_3d_text> final {
    std::uint16_t id;
    std::int32_t color;
    types::vector_3d pos;
    float draw_distance;
    std::uint8_t test_los;
    std::uint16_t attached_player_id;
    std::uint16_t attached_vehicle_id;
    std::string text;

    explicit event(bit_stream* stream);
}; // struct event<event_id::create_3d_text> final

template<>
struct event<event_id::remove_3d_text> final {
    std::uint16_t id;

    explicit event(bit_stream* stream)
        : id(stream->read<std::uint16_t>()) {}
}; // struct event<event_id::remove_3d_text> final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_3D_TEXT_H
