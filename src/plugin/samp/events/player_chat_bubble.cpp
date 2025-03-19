#include "plugin/samp/events/player_chat_bubble.h"
#include "plugin/string_utils.h"

plugin::samp::event<plugin::samp::event_id::player_chat_bubble>::event(bit_stream* stream) {
    player_id = stream->read<std::uint16_t>();
    color = types::color::rgba(stream->read<std::uint32_t>());
    distance = stream->read<float>();
    duration = stream->read<std::int32_t>();
    message = string_utils::to_utf8(stream->read_string<std::uint8_t>());
}
