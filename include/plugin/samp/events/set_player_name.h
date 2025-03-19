#ifndef GADMIN_PLUGIN_SAMP_EVENTS_SET_PLAYER_NAME_H
#define GADMIN_PLUGIN_SAMP_EVENTS_SET_PLAYER_NAME_H

#include "plugin/samp/events/event.h"

namespace plugin::samp {

template<>
struct event<event_id::set_player_name> {
    std::string nickname;
    std::uint16_t id;

    explicit event(bit_stream* stream)
        : id(stream->read<std::uint16_t>()),
          nickname(stream->read_string<std::uint8_t>()) {}
}; // struct event<event_id::set_player_name>

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_SET_PLAYER_NAME_H
