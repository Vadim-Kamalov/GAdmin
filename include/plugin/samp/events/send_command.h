#ifndef GADMIN_PLUGIN_SAMP_EVENTS_SEND_COMMAND_H
#define GADMIN_PLUGIN_SAMP_EVENTS_SEND_COMMAND_H

#include "plugin/samp/events/event.h"
#include "plugin/string_utils.h"

namespace plugin::samp {

template<>
struct event<event_id::send_command, event_type::outgoing_rpc> {
    std::string command;
    explicit event(bit_stream* stream)
        : command(string_utils::to_utf8(stream->read_string<std::uint32_t>())) {}
}; // struct event<event_id::send_command, event_type::outgoing_rpc>

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_SEND_COMMAND_H
