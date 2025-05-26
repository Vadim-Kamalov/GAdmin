#ifndef GADMIN_PLUGIN_SAMP_EVENTS_SEND_COMMAND_H
#define GADMIN_PLUGIN_SAMP_EVENTS_SEND_COMMAND_H

#include "plugin/samp/events/event.h"
#include "plugin/string_utils.h"

namespace plugin::samp {

template<>
class event<event_id::send_command, event_type::outgoing_rpc> {
private:
    bit_stream* stream;
public:
    std::string command;
    
    void write_command(const std::string_view& new_command) const;

    explicit event(bit_stream* stream)
        : command(string_utils::to_utf8(stream->read_string<std::uint32_t>())),
          stream(stream) {}
}; // class event<event_id::send_command, event_type::outgoing_rpc>

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_SEND_COMMAND_H
