#ifndef GADMIN_PLUGIN_SAMP_EVENTS_SERVER_CONNECT_H
#define GADMIN_PLUGIN_SAMP_EVENTS_SERVER_CONNECT_H

#include "plugin/samp/events/event.h"
#include "plugin/types/color.h"

namespace plugin::samp {

template<>
struct event<event_id::server_connect> final {
    std::uint16_t id;
    types::color color;
    bool npc = false;
    std::string nickname;

    explicit event(bit_stream* stream);
}; // struct event<event_id::server_connect> final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_SERVER_CONNECT_H
