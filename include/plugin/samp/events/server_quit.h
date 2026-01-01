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

#ifndef GADMIN_PLUGIN_SAMP_EVENTS_SERVER_QUIT_H
#define GADMIN_PLUGIN_SAMP_EVENTS_SERVER_QUIT_H

#include "plugin/samp/events/event.h"

namespace plugin::samp {

template<>
struct event<event_id::server_quit> final {
    std::uint16_t id; ///< Player's ID.

    /// Reason of the disconnect in the range 0-2, where:
    ///
    ///     - 0: crash or timeout;
    ///     - 1: manual disconnect (`/q`);
    ///     - 2: disconnected by the server (`/kick or `/ban`);
    std::uint8_t reason;

    /// Construct an event.
    ///
    /// @param bit_stream[in] Bit stream with the event parameters.
    explicit event(bit_stream* stream) {
        stream->read_into(id, reason);
    }
}; // struct event<event_id::server_quit> final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_SERVER_QUIT_H
