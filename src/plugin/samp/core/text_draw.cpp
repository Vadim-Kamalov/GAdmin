#include "plugin/samp/core/text_draw.h"

plugin::samp::text_draw::text_draw(samp::bit_stream* stream) {
    id = stream->read<std::uint16_t>();
    stream->ignore_bytes(0x3F);
    text = stream->read_string<std::uint16_t>();
}

plugin::samp::text_draw_string_setter::text_draw_string_setter(samp::bit_stream* stream) {
    id = stream->read<std::uint16_t>();
    text = stream->read_string<std::uint16_t>();
}

plugin::samp::text_draw_hider::text_draw_hider(samp::bit_stream* stream) {
    id = stream->read<std::uint16_t>();
}
