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

#include "plugin/samp/core/dialog.h"
#include "plugin/samp/network/bit_stream.h"

plugin::types::versioned_address_container<std::uintptr_t>
plugin::samp::dialog::instance_container = { 0x21A0B8, 0x26E898, 0x26EB50, 0x2AC9E0 };

auto plugin::samp::dialog::send_response(std::uint16_t id, const button& button,
                                         std::uint16_t list_item, const std::string_view& input)
    noexcept -> void
{
    bit_stream stream;
    stream.write(id);
    stream.write(std::to_underlying(button));
    stream.write(list_item);
    stream.write(static_cast<std::uint8_t>(input.size()));
    stream.write(input);
    stream.send_rpc(send_response_id);
}

auto plugin::samp::dialog::is_active() noexcept -> bool {
    return active_offset.read(instance_container->read());
}
