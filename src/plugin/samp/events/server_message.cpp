#include "plugin/samp/events/server_message.h"

void
plugin::samp::event<plugin::samp::event_id::server_message>::write_text(const std::string_view& new_text) const {
    stream->reset_bit_stream();
    stream->write(color.cast<types::color_type::rgba>());
    stream->write_string<std::uint32_t>(new_text);
}
