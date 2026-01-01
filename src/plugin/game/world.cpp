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

#include "plugin/game/world.h"
#include "plugin/game/entity.h"
#include <memory>

auto plugin::game::world::process_line_of_sight(const types::vector_3d& origin, const types::vector_3d& target,
                                                const types::options<line_of_sight_condition>& conditions)
    noexcept -> std::optional<processed_line_of_sight>
{
    types::vector_3d* vector_origin = const_cast<types::vector_3d*>(std::addressof(origin));
    types::vector_3d* vector_target = const_cast<types::vector_3d*>(std::addressof(target));
    std::uintptr_t entity_ptr = 0;
    
    struct {
        types::vector_3d pos;
        float unused;
        types::vector_3d normal;
    } point;

    if (!process_line_of_sight_address(vector_origin, vector_target, reinterpret_cast<std::uintptr_t>(&point), &entity_ptr,
        conditions.has_value(line_of_sight_condition::buildings), conditions.has_value(line_of_sight_condition::vehicles),
        conditions.has_value(line_of_sight_condition::peds), conditions.has_value(line_of_sight_condition::objects),
        conditions.has_value(line_of_sight_condition::dummies), conditions.has_value(line_of_sight_condition::see_through),
        conditions.has_value(line_of_sight_condition::camera_ignore), conditions.has_value(line_of_sight_condition::shoot_through)))
    {
        return {};
    }

    return processed_line_of_sight {
        .pos = point.pos,
        .normal = point.normal,
        .entity = entity(entity_ptr)
    };
}
