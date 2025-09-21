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

#include "plugin/samp/events/player_death_notification.h"
#include "plugin/game/weapon.h"
#include "plugin/samp/core/player_pool.h"

auto plugin::samp::event<plugin::samp::event_id::player_death_notification>::to_string() const -> std::string {
    auto killed_nickname = samp::player_pool::get_nickname(killed_id);

    if (!killed_nickname)
        return "";

    if (killer_id != id_none) {
        auto killer_nickname = samp::player_pool::get_nickname(killer_id);

        if (!killer_nickname)
            return "";
        
        return std::format("{}[{}] убил {}[{}] с помощью {}.", *killer_nickname,
                           killer_id, *killed_nickname, killed_id, get_reason());
    }

    return std::format("{}[{}] погиб от {}.", *killed_nickname, killed_id, get_reason());
}

auto plugin::samp::event<plugin::samp::event_id::player_death_notification>::get_reason() const
    -> std::string
{
    switch (reason) {
        case special_reason_car: return "Vehicle";
        case special_reason_helicopter: return "Helicopter";
        case special_reason_explosion: return "Explosion";
        case special_reason_drowned: return "Drowned";
        case special_reason_suicide: return "Suicide";
        case 0 ... 18: case 22 ... 46: return game::weapon_names[reason];
        default: return "Unknown";
    }
}

plugin::samp::event<plugin::samp::event_id::player_death_notification>::event(bit_stream* stream) {
    stream->read_into(killer_id, killed_id, reason);
}
