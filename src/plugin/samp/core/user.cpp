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

#include "plugin/samp/core/user.h"
#include "plugin/samp/core/player_pool.h"

plugin::types::versioned_address_container<std::uintptr_t, plugin::types::version_container_option::offsets>
plugin::samp::user::local_player_offsets = { 0x22, 0x2F3A, 0x26, 0x1E };

plugin::types::versioned_address_container<plugin::types::zstring_t, plugin::types::version_container_option::offsets>
plugin::samp::user::name_offsets = { 0xA, 0x2F22, 0xA, 0x6 };

plugin::types::versioned_address_container<std::uint16_t, plugin::types::version_container_option::offsets>
plugin::samp::user::id_offsets = { 0x4, 0x2F1C, 0x4, 0x0 };

plugin::types::versioned_address_container<plugin::signatures::local_player_chat_t>
plugin::samp::user::local_player_chat_container = { 0x57F0, 0x5820, 0x5A10, 0x5860 };

plugin::types::versioned_address_container<plugin::signatures::get_local_player_ping_t>
plugin::samp::user::get_local_player_ping_container = { 0x6A200, 0x6E150, 0x6E8C0, 0x6E2F0 };

plugin::types::versioned_address_container<plugin::signatures::get_local_player_color_as_argb>
plugin::samp::user::get_local_player_color_container = { 0x3D90, 0x3DA0, 0x3F20, 0x3E20 };

auto plugin::samp::user::get_color() noexcept -> types::color {
    return types::color::argb(get_local_player_color_container->invoke(get_local_player()));
}

auto plugin::samp::user::get_local_player() noexcept -> std::uintptr_t {
    return local_player_offsets->read(player_pool::instance());
}

auto plugin::samp::user::get_id() noexcept -> std::uint16_t {
    return id_offsets->read(player_pool::instance());
}

auto plugin::samp::user::get_name() noexcept -> std::string {
    return name_offsets->read(player_pool::instance());
}

auto plugin::samp::user::get_ping() noexcept -> int {
    return get_local_player_ping_container->invoke(player_pool::instance());
}
