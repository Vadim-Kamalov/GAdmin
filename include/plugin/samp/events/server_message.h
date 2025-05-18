#ifndef GADMIN_PLUGIN_SAMP_EVENTS_SERVER_MESSAGE_H
#define GADMIN_PLUGIN_SAMP_EVENTS_SERVER_MESSAGE_H

#include "plugin/samp/events/event.h"
#include "plugin/string_utils.h"
#include "plugin/types/color.h"

namespace plugin::samp {

template<>
class event<event_id::server_message> {
private:
    bit_stream* stream;
public:
    types::color color;
    std::string text;

    void write(const std::string_view& new_text, const types::color& color) const;
    inline void write_text(const std::string_view& new_text) const;

    explicit event(bit_stream* stream)
        : stream(stream),
          color(types::color::rgba(stream->read<std::int32_t>())),
          text(string_utils::to_utf8(stream->read_string<std::int32_t>())) {}
}; // class event_id<event_id::server_message>

} // namespace plugin::samp

inline void
plugin::samp::event<plugin::samp::event_id::server_message>::write_text(const std::string_view& new_text) const {
    write(new_text, color);
}

#endif // GADMIN_PLUGIN_SAMP_EVENTS_SERVER_MESSAGE_H
