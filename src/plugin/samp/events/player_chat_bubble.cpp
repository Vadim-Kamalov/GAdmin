/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2026 The Contributors.
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

#include "plugin/samp/events/player_chat_bubble.h"
#include "plugin/string_utils.h"

plugin::samp::event<plugin::samp::event_id::player_chat_bubble>::event(bit_stream* stream) {
    player_id = stream->read<std::uint16_t>();
    color = types::color::rgba(stream->read<std::uint32_t>());
    distance = stream->read<float>();
    duration = stream->read<std::int32_t>();
    message = string_utils::to_utf8(stream->read_string<std::uint8_t>());
}
