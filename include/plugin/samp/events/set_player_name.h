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

#ifndef GADMIN_PLUGIN_SAMP_EVENTS_SET_PLAYER_NAME_H
#define GADMIN_PLUGIN_SAMP_EVENTS_SET_PLAYER_NAME_H

#include "plugin/samp/events/event.h"

namespace plugin::samp {

template<>
struct event<event_id::set_player_name> final {
    std::uint16_t id;     ///< Player's ID.
    std::string nickname; ///< New player's nickname.

    /// Construct an event.
    ///
    /// @param bit_stream[in] Bit stream with the event parameters.
    explicit event(bit_stream* stream)
        : id(stream->read<std::uint16_t>()),
          nickname(stream->read_string<std::uint8_t>()) {}
}; // struct event<event_id::set_player_name> final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_SET_PLAYER_NAME_H
