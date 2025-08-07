#include "plugin/samp/events/server_connect.h"

plugin::samp::event<plugin::samp::event_id::server_connect>::event(bit_stream* stream) {
    id = stream->read<std::uint16_t>();
    color = types::color::rgba(stream->read<std::uint32_t>());
    npc = stream->read<std::uint8_t>();
    nickname = stream->read_string<std::uint8_t>();
}
