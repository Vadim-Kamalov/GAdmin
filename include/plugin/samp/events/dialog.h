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

#ifndef GADMIN_PLUGIN_SAMP_EVENTS_DIALOG_H
#define GADMIN_PLUGIN_SAMP_EVENTS_DIALOG_H

#include "plugin/samp/core/dialog.h"
#include "plugin/samp/events/event.h"
#include "plugin/string_utils.h"
#include <utility>

namespace plugin::samp {

template<>
class event<event_id::show_dialog> final {
private:
    bit_stream* stream;
public:
    std::uint16_t id;                            ///< Dialog's ID.
    dialog::style style;                         ///< Dialog's style.
    std::string title;                           ///< Dialog's title.
    std::string text;                            ///< Dialog's text.
    std::pair<std::string, std::string> buttons; ///< Dialog's buttons' text.

    /// Check if the dialog is available. Equivalent to `id != dialog::invalid_id`;
    ///
    /// @return True if the dialog is available.
    inline auto is_available() const -> bool;

    /// Check if the dialog is available. Equivalent to `is_available()`.
    inline explicit operator bool() const;
    
    /// Send response to the current dialog with specific button.
    ///
    /// @param button[in]    Dialog button.
    /// @param list_item[in] Dialog list item. Can be set to `list_item_none`, if there's no need for this.
    /// @parma input[in]     Dialog text to set in the input. Can be set to empty string, if there's no need for this.
    auto send_response(const dialog::button& button, std::uint16_t list_item = dialog::list_item_none,
                       const std::string_view& input = "") const -> void;

    /// Update dialog text on the user side.
    ///
    /// @param text[in] New dialog text.
    auto write_text(const std::string_view& text) const -> void;

    /// Construct an event.
    ///
    /// @param bit_stream[in] Bit stream with the event parameters.
    explicit event(bit_stream* stream);
}; // class event<event_id::show_dialog> final

template<>
struct event<event_id::dialog_response, event_type::outgoing_rpc> final {
    std::uint16_t dialog_id;    ///< Dialog's ID.
    dialog::button button;      ///< Selected button by the user in the dialog.
    std::uint16_t list_item_id; ///< Selected list item by the user in the dialog.
    std::string input;          ///< Input text sent by the user in the dialog.

    /// Construct an event.
    ///
    /// @param bit_stream[in] Bit stream with the event parameters.
    explicit event(bit_stream* stream)
        : dialog_id(stream->read<std::uint16_t>()),
          button(static_cast<dialog::button>(stream->read<std::uint8_t>())),
          list_item_id(stream->read<std::uint16_t>()),
          input(string_utils::to_utf8(stream->read_string<std::uint8_t>())) {}
}; // struct event<event_id::dialog_response, event_type::outgoing_rpc> final

} // namespace plugin::samp

inline auto plugin::samp::event<plugin::samp::event_id::show_dialog>::is_available() const -> bool {
    return id != dialog::invalid_id;
}

inline plugin::samp::event<plugin::samp::event_id::show_dialog>::operator bool() const {
    return is_available();
}

#endif // GADMIN_PLUGIN_SAMP_EVENTS_DIALOG_H
