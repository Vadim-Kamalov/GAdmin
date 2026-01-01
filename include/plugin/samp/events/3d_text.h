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

#ifndef GADMIN_PLUGIN_SAMP_EVENTS_3D_TEXT_H
#define GADMIN_PLUGIN_SAMP_EVENTS_3D_TEXT_H

#include "plugin/samp/events/event.h"
#include "plugin/types/simple.h"

namespace plugin::samp {

template<>
struct event<event_id::create_3d_text> final {
    std::uint16_t id;                  ///< 3D text ID.
    std::int32_t color;                ///< 3D text color.
    types::vector_3d pos;              ///< 3D text coordinates.
    float draw_distance;               ///< 3D text draw distance.
    std::uint8_t test_los;             ///< Result of the line of sight test.
    std::uint16_t attached_player_id;  ///< ID of the playe if 3D text is attached to it.
    std::uint16_t attached_vehicle_id; ///< ID of the vehicle if 3D text is attached to it.
    std::string text;                  ///< Actual text of the 3D text.

    /// Construct an event.
    ///
    /// @param bit_stream[in] Bit stream with the event parameters.
    explicit event(bit_stream* stream);
}; // struct event<event_id::create_3d_text> final

template<>
struct event<event_id::remove_3d_text> final {
    std::uint16_t id; ///< ID of the removed 3D text.

    /// Construct an event.
    ///
    /// @param bit_stream[in] Bit stream with the event parameters.
    explicit event(bit_stream* stream)
        : id(stream->read<std::uint16_t>()) {}
}; // struct event<event_id::remove_3d_text> final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_3D_TEXT_H
