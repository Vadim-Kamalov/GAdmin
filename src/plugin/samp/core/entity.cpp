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

#include "plugin/samp/core/entity.h"

plugin::types::versioned_address_container<plugin::signatures::get_model_index_t>
plugin::samp::entity::get_model_index_container = { 0x9A670, 0x9E920, 0x9F030, 0x9EE70 };

auto plugin::samp::entity::is_available() const -> bool {
    return handle.is_available() && game_handle.read(*handle) != 0;
}

auto plugin::samp::entity::get_model_index() const -> int {
    return get_model_index_container->invoke(*handle);
}

auto plugin::samp::entity::operator==(const entity& other) const -> bool {
    return *handle == *other.handle;
}
