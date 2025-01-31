#include "plugin/samp/core/synchronization.h"

plugin::samp::basic_synchronization::basic_synchronization(samp::bit_stream* stream, int skip_bytes, bool check_keys) {
    stream->ignore_bytes(0x1);

    player_id = stream->read<std::uint16_t>();

    if (skip_bytes != 0)
        stream->ignore_bytes(skip_bytes);

    if (check_keys) {
        if (stream->read<bool>())
            left_right_keys = stream->read<std::uint16_t>();

        if (stream->read<bool>())
            up_down_keys = stream->read<std::uint16_t>();
    } else {
        left_right_keys = stream->read<std::uint16_t>();
        up_down_keys = stream->read<std::uint16_t>();
    }

    keys_data = stream->read<std::uint16_t>();
}

plugin::samp::bullet_synchronization::bullet_synchronization(samp::bit_stream* stream) {
    stream->ignore_bytes(0x1);

    player_id = stream->read<std::uint16_t>();
    hit_type = stream->read<std::uint8_t>();
    hit_id = stream->read<std::uint16_t>();
    origin_x = stream->read<float>();
    origin_y = stream->read<float>();
    origin_z = stream->read<float>();
    hit_pos_x = stream->read<float>();
    hit_pos_y = stream->read<float>();
    hit_pos_z  = stream->read<float>();
    offset_x = stream->read<float>();
    offset_y = stream->read<float>();
    offset_z = stream->read<float>();
    weapon_id = stream->read<std::uint8_t>();
}
