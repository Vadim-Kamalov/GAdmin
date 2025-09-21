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
