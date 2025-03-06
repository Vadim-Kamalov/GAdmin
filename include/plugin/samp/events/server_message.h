#ifndef GADMIN_PLUGIN_SAMP_EVENTS_SERVER_MESSAGE_H
#define GADMIN_PLUGIN_SAMP_EVENTS_SERVER_MESSAGE_H

#include "plugin/encoding.h"
#include "plugin/samp/events/event.h"
#include "plugin/types/color.h"

namespace plugin::samp {

template<>
struct event<event_id::server_message> {
    types::color color;
    std::string text;

    explicit event(bit_stream* stream)
        : color(types::color::rgba(stream->read<std::int32_t>())),
          text(encoding::to_utf8(stream->read_string<std::int32_t>())) {}
}; // struct event_id<event_id::server_message>

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_SERVER_MESSAGE_H
