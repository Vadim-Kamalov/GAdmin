#ifndef GADMIN_PLUGIN_SAMP_EVENTS_PLAYER_CHAT_BUBBLE_H
#define GADMIN_PLUGIN_SAMP_EVENTS_PLAYER_CHAT_BUBBLE_H

#include "plugin/samp/events/event.h"
#include "plugin/types/color.h"

namespace plugin::samp {

template<>
struct event<event_id::player_chat_bubble> {
    std::uint16_t player_id;
    types::color color;
    std::int32_t duration;
    std::string message;
    float distance;

    explicit event(bit_stream* stream);
}; // struct event<event_id::player_chat_bubble>

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_PLAYER_CHAT_BUBBLE_H
