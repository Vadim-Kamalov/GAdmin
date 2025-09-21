/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#include "plugin/samp/events/synchronization.h"

plugin::samp::common_synchronization_info::common_synchronization_info(bit_stream* stream, int skip_bytes, bool check_keys) {
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

plugin::samp::event<plugin::samp::event_id::bullet_synchronization, plugin::samp::event_type::incoming_packet>::event(bit_stream* stream) {
    stream->read_into(player_id, hit_type, hit_id, origin, hit, offset, weapon_id);
}
