#ifndef GADMIN_PLUGIN_SAMP_EVENTS_SEND_CHAT_H
#define GADMIN_PLUGIN_SAMP_EVENTS_SEND_CHAT_H

#include "plugin/samp/events/event.h"
#include "plugin/string_utils.h"

namespace plugin::samp {

template<>
struct event<event_id::send_chat, event_type::outgoing_rpc> final {
    std::string text;
    
    explicit event(bit_stream* stream)
        : text(string_utils::to_utf8(stream->read_string<std::uint8_t>())) {}
}; // struct event<event_id::send_chat, event_type::outgoing_rpc> final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_SEND_CHAT_H
