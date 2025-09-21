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

#ifndef GADMIN_PLUGIN_SAMP_EVENTS_DIALOG_H
#define GADMIN_PLUGIN_SAMP_EVENTS_DIALOG_H

#include "plugin/samp/core/dialog.h"
#include "plugin/samp/events/event.h"
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

} // namespace plugin::samp

inline auto plugin::samp::event<plugin::samp::event_id::show_dialog>::is_available() const -> bool {
    return id != dialog::invalid_id;
}

inline plugin::samp::event<plugin::samp::event_id::show_dialog>::operator bool() const {
    return is_available();
}

#endif // GADMIN_PLUGIN_SAMP_EVENTS_DIALOG_H
