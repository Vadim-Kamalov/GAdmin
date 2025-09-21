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

#ifndef GADMIN_PLUGIN_SAMP_EVENTS_SEND_COMMAND_H
#define GADMIN_PLUGIN_SAMP_EVENTS_SEND_COMMAND_H

#include "plugin/samp/events/event.h"
#include "plugin/string_utils.h"

namespace plugin::samp {

template<>
class event<event_id::send_command, event_type::outgoing_rpc> final {
private:
    bit_stream* stream;
public:
    std::string command; ///< Command text. Always starts with a `/` character.
    
    /// Change command text with updating it in the Bit Stream.
    ///
    /// @param text[in] New command text.
    auto write_command(const std::string_view& new_command) const -> void;

    /// Construct an event.
    ///
    /// @param bit_stream[in] Bit stream with the event parameters.
    explicit event(bit_stream* stream)
        : command(string_utils::to_utf8(stream->read_string<std::uint32_t>())),
          stream(stream) {}
}; // class event<event_id::send_command, event_type::outgoing_rpc>

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_SEND_COMMAND_H
