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

#include "plugin/samp/events/dialog.h"
#include "plugin/string_utils.h"
#include <utility>

auto plugin::samp::event<plugin::samp::event_id::show_dialog>::send_response(const dialog::button& button,
                                                                             std::uint16_t list_item,
                                                                             const std::string_view& input) const
    -> void
{
    dialog::send_response(id, button, list_item, input);
}

auto plugin::samp::event<plugin::samp::event_id::show_dialog>::write_text(const std::string_view& text) const
    -> void
{
    stream->reset_bit_stream();
    stream->write(id);
    stream->write(std::to_underlying(style));
    stream->write_string<std::uint8_t>(title);
    stream->write_string<std::uint8_t>(buttons.first);
    stream->write_string<std::uint8_t>(buttons.second);
    stream->write_encoded(string_utils::to_cp1251(std::string(text)));
}

plugin::samp::event<plugin::samp::event_id::show_dialog>::event(bit_stream* stream)
    : stream(stream),
      id(stream->read<std::uint16_t>())
{
    if (id == dialog::invalid_id)
        return;

    style = static_cast<dialog::style>(stream->read<std::uint8_t>());
    title = string_utils::to_utf8(stream->read_string<std::uint8_t>());

    std::string first_button = string_utils::to_utf8(stream->read_string<std::uint8_t>());
    std::string second_button = string_utils::to_utf8(stream->read_string<std::uint8_t>());

    buttons = { first_button, second_button };
    text = string_utils::to_utf8(stream->read_encoded(4096));
}
