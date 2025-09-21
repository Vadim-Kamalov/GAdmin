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

#include "plugin/samp/events/server_message.h"
#include "plugin/string_utils.h"

auto plugin::samp::event<plugin::samp::event_id::server_message>::write(const std::string_view& new_text,
                                                                        const types::color& new_color) const
    -> void
{
    stream->reset_bit_stream();
    stream->write(new_color.cast<types::color_type::rgba>());
    stream->write_string<std::uint32_t>(string_utils::to_cp1251(std::string(new_text)));
}
