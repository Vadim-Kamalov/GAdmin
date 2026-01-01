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

#include "plugin/game/entity.h"
#include "plugin/game/vehicle.h"

auto plugin::game::entity::set_coordinates(const types::vector_3d& pos) const -> void {
    position_offset_in_matrix.write(pos, matrix_offset.read(*handle));
}

auto plugin::game::entity::teleport(const types::vector_3d& pos) const -> void {
    set_coordinates(pos);
}

auto plugin::game::entity::is_on_screen() const -> bool {
    return is_on_screen_address(*handle);
}

auto plugin::game::entity::get_model_index() const -> std::uint16_t {
    return model_index_offset.read(*handle);
}

auto plugin::game::entity::get_position() const -> types::vector_3d {
    return position_offset_in_matrix.read(matrix_offset.read(*handle));
}

auto plugin::game::entity::get_vehicle() const -> vehicle {
    if (!is_vehicle_pointer_valid_address(*handle))
        return vehicle(0);

    return vehicle(*handle);
}

auto plugin::game::entity::operator==(const entity& other) const -> bool {
    return *handle == *other.handle;
}
