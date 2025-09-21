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

#include "plugin/samp/core/remote_player.h"

plugin::types::versioned_address_container<plugin::samp::ped, plugin::types::version_container_option::offsets>
plugin::samp::remote_player::ped_container = { 0x0, 0x0, 0x1DD, 0x4 };

plugin::types::versioned_address_container<plugin::samp::vehicle, plugin::types::version_container_option::offsets>
plugin::samp::remote_player::vehicle_container = { 0x4, 0x4, 0x1E1, 0x8 };

plugin::types::versioned_address_container<float, plugin::types::version_container_option::offsets>
plugin::samp::remote_player::armor_container = { 0x1B8, 0x1AC, 0x1AC, 0x1AC };

plugin::types::versioned_address_container<plugin::signatures::get_color_as_argb>
plugin::samp::remote_player::get_color_container = { 0x12A00, 0x15C10, 0x16180, 0x15E30 };

plugin::types::versioned_address_container<std::uint16_t, plugin::types::version_container_option::offsets>
plugin::samp::remote_player::id_container = { 0xAB, 0x8, 0x1E5, 0x0 };

auto plugin::samp::remote_player::is_available() const -> bool {
    return handle.is_available();
}

auto plugin::samp::remote_player::get_ped() const -> ped {
    return ped_container->read(*handle);
}

auto plugin::samp::remote_player::get_vehicle() const -> vehicle {
    return vehicle_container->read(*handle);
}

auto plugin::samp::remote_player::get_armor() const -> float {
    return armor_container->read(*handle);
}

auto plugin::samp::remote_player::get_color() const -> types::color {
    return types::color::argb(get_color_container->invoke(*handle));
}

auto plugin::samp::remote_player::get_id() const -> std::uint16_t {
    return id_container->read(*handle);
}
