#include "plugin/samp/core/3d_text.h"
#include "plugin/encoding.h"

plugin::samp::creator_3d_text::creator_3d_text(samp::bit_stream* stream) {
    id = stream->read<std::uint16_t>();
    color = stream->read<std::int32_t>();
    pos_x = stream->read<float>();
    pos_y = stream->read<float>();
    pos_z = stream->read<float>();
    draw_distance = stream->read<float>();
    test_los = stream->read<std::uint8_t>();
    attached_player_id = stream->read<std::uint16_t>();
    attached_vehicle_id = stream->read<std::uint16_t>();
    text = encoding::to_utf8(stream->read_encoded(4096));
}

plugin::samp::remover_3d_text::remover_3d_text(samp::bit_stream* stream) {
    id = stream->read<std::uint16_t>();
}
