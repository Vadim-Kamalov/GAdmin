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

#ifndef GADMIN_PLUGIN_SAMP_EVENTS_SERVER_MESSAGE_H
#define GADMIN_PLUGIN_SAMP_EVENTS_SERVER_MESSAGE_H

#include "plugin/samp/events/event.h"
#include "plugin/string_utils.h"
#include "plugin/types/color.h"

namespace plugin::samp {

template<>
class event<event_id::server_message> final {
private:
    bit_stream* stream;
public:
    types::color color; ///< Chat Message's color.
    std::string text;   ///< Chat Message's text.

    /// Update message text and color on the user side.
    ///
    /// @param new_text[in] New message's text.
    /// @param color[in]    New message's color.
    auto write(const std::string_view& new_text, const types::color& color) const -> void;
    
    /// Update message text with preserving current color on the user side.
    ///
    /// @param new_text[in] New message's text.
    inline auto write_text(const std::string_view& new_text) const -> void;

    /// Construct an event.
    ///
    /// @param bit_stream[in] Bit stream with the event parameters.
    explicit event(bit_stream* stream)
        : stream(stream),
          color(types::color::rgba(stream->read<std::int32_t>())),
          text(string_utils::to_utf8(stream->read_string<std::int32_t>())) {}
}; // class event_id<event_id::server_message> final

} // namespace plugin::samp

inline auto plugin::samp::event<plugin::samp::event_id::server_message>::write_text(const std::string_view& new_text) const -> void {
    write(new_text, color);
}

#endif // GADMIN_PLUGIN_SAMP_EVENTS_SERVER_MESSAGE_H
