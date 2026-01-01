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

#ifndef GADMIN_PLUGIN_SAMP_EVENTS_TEXT_DRAW_H
#define GADMIN_PLUGIN_SAMP_EVENTS_TEXT_DRAW_H

#include "plugin/samp/events/event.h"

namespace plugin::samp {

template<>
struct event<event_id::show_text_draw> final {
    std::uint16_t id; ///< Text Draw's ID.
    std::string text; ///< Text Draw's text.

    /// Construct an event.
    ///
    /// @param bit_stream[in] Bit stream with the event parameters.
    explicit event(bit_stream* stream);
}; // struct event<event_id::show_text_traw> final

template<>
struct event<event_id::hide_text_draw> final {
    std::uint16_t id; ///< Text Draw's ID.

    /// Construct an event.
    ///
    /// @param bit_stream[in] Bit stream with the event parameters.
    explicit event(bit_stream* stream);
}; // struct event<event_id::hide_text_draw> final

template<>
struct event<event_id::set_text_draw_string> final {
    std::uint16_t id; ///< Text Draw's ID.
    std::string text; ///< New Text Draw's text.

    /// Construct an event.
    ///
    explicit event(bit_stream* stream);
}; // struct event<event_id::set_text_draw_string> final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_TEXT_DRAW_H
