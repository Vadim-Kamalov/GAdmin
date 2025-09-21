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

#include "plugin/game/placeable.h"

auto plugin::game::placeable::is_locked() const -> bool {
    return physical_flags_offset.read(*handle).locked;
}

auto plugin::game::placeable::set_lock(bool state) const -> void {
    auto entity_flags = reinterpret_cast<int*>(*handle + *entity_flags_offset);
    auto physical_flags = reinterpret_cast<physical_flags_t*>(*handle + *physical_flags_offset);

    *entity_flags |= !state; // bool uses_collision
    physical_flags->locked = state;
    physical_flags->soft = state;
}

auto plugin::game::placeable::get_heading() const -> float {
    return clamp_angle(get_placeable_rotation(*handle) * rad_to_deg_multiplier);
}

auto plugin::game::placeable::set_heading_in_rad(float angle) const -> void {
    // SET_CHAR_HEADING (0x173) opcode implementation updates
    // entity RW's, but if **we** update that then it causes
    // problems in changing coordinates, so we ignore it.
    set_placeable_heading(*handle, angle);
}

auto plugin::game::placeable::set_heading_in_deg(float angle) const -> void {
    set_heading_in_rad(clamp_angle(angle) * deg_to_rad_multiplier);
}

auto plugin::game::placeable::clamp_angle(float angle) const -> float {
    if (angle < 0)
        angle += 360;

    if (angle > 360)
        angle -= 360;

    return angle;
}

auto plugin::game::placeable::set_heading(float angle) const -> void {
    set_heading_in_deg(angle);
}
