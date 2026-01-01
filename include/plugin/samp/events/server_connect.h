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

#ifndef GADMIN_PLUGIN_SAMP_EVENTS_SERVER_CONNECT_H
#define GADMIN_PLUGIN_SAMP_EVENTS_SERVER_CONNECT_H

#include "plugin/samp/events/event.h"
#include "plugin/types/color.h"

namespace plugin::samp {

template<>
struct event<event_id::server_connect> final {
    std::uint16_t id;     ///< Player's or NPC's ID.
    types::color color;   ///< Player's or NPC's color.
    bool npc = false;     ///< Whether is NPC connected or not.
    std::string nickname; ///< Player's or NPC's nickname.

    /// Construct an event.
    ///
    /// @param bit_stream[in] Bit stream with the event parameters.
    explicit event(bit_stream* stream);
}; // struct event<event_id::server_connect> final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_SERVER_CONNECT_H
