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

#include "plugin/samp/core/server_settings.h"

auto plugin::samp::server_settings::get_name_tags_render_distance() const -> float {
    return name_tags_render_distance_offset.read(*pointer);
}

auto plugin::samp::server_settings::set_name_tags_render_distance(float distance) const
    -> void
{
    name_tags_render_distance_offset.write(distance, *pointer);
}
    
auto plugin::samp::server_settings::set_name_tags_render_behind_wall(bool state) const
    -> void
{
    name_tags_render_behind_wall_offset.write(state, *pointer);
}

auto plugin::samp::server_settings::set_name_tags_render_state(bool state) const -> void {
    name_tags_render_state.write(state, *pointer);
}
