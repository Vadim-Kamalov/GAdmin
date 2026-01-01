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

#include "plugin/samp/events/3d_text.h"
#include "plugin/string_utils.h"

plugin::samp::event<plugin::samp::event_id::create_3d_text>::event(bit_stream* stream) {
    stream->read_into(id, color, pos, draw_distance, test_los,
                      attached_player_id, attached_vehicle_id);
        
    text = string_utils::to_utf8(stream->read_encoded(4096));
}
