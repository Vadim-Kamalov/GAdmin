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

#include "plugin/game/game.h"
#include "plugin/types/address.h"

static plugin::types::address<plugin::signatures::calc_screen_coords> calc_screen_coords = 0x71DAB0;

auto plugin::game::get_screen_resolution() noexcept -> std::pair<float, float> {
    static types::address<int> resolution_x = 0xC9C040;
    static types::address<int> resolution_y = 0xC9C044;
    return { resolution_x.read(), resolution_y.read() };
}

auto plugin::game::convert_3d_coords_to_screen(const types::vector_3d& coords)
    noexcept -> types::vector_3d
{
    types::vector_3d result;

    if (!calc_screen_coords(const_cast<types::vector_3d*>(&coords), &result))
        return { 0, 0, 0 };

    return result;
}
