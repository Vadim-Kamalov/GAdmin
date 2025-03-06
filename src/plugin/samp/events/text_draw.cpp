#include "plugin/samp/events/text_draw.h"

plugin::samp::event<plugin::samp::event_id::show_text_draw>::event(bit_stream* stream) {
    id = stream->read<std::uint16_t>();
    stream->ignore_bytes(0x3F);
    text = stream->read_string<std::uint16_t>();
}

plugin::samp::event<plugin::samp::event_id::hide_text_draw>::event(bit_stream* stream) {
    id = stream->read<std::uint16_t>();
}

plugin::samp::event<plugin::samp::event_id::set_text_draw_string>::event(bit_stream* stream) {
    id = stream->read<std::uint16_t>();
    text = stream->read_string<std::uint16_t>();
}
