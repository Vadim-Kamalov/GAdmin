#ifndef GADMIN_PLUGIN_SAMP_EVENTS_SERVER_QUIT_H
#define GADMIN_PLUGIN_SAMP_EVENTS_SERVER_QUIT_H

#include "plugin/samp/events/event.h"

namespace plugin::samp {

template<>
struct event<event_id::server_quit> {
    std::uint16_t id;
    std::uint8_t reason;

    explicit event(bit_stream* stream) {
        stream->read_into(id, reason);
    }
}; // struct event<event_id::server_quit>

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_SERVER_QUIT_H
