/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2024-2025 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#include "plugin/cheats/tracers.h"
#include "plugin/gui/icon.h"
#include "plugin/gui/notify.h"
#include "plugin/gui/style.h"
#include "plugin/samp/events/synchronization.h" // IWYU pragma: keep
#include "plugin/server/spectator.h"
#include "plugin/game/game.h"
#include "plugin/plugin.h"
#include "plugin/server/user.h"
#include "plugin/types/color.h"

auto plugin::cheats::tracers::hotkey_callback(gui::hotkey&) -> void {
    current_tracers.clear();
    gui::notify::send(gui::notification("Трассера удалены", "Трассера на экране успешно удалены!", ICON_INFO));
}

auto plugin::cheats::tracers::on_bullet_synchronization(const samp::packet<samp::event_id::bullet_synchronization>& synchronization)
    -> bool
{
    auto cheat_configuration = (*configuration)["cheats"]["tracers"];

    if (!cheat_configuration["use"] || !server::user::is_on_alogin())
        return true;

    if (cheat_configuration["only_from_spectator"] && (!server::spectator::is_active()
        || synchronization.player_id != server::spectator::id))
    {
        return true;
    }

    if (current_tracers.size() == cheat_configuration["limit"])
        current_tracers.pop_back();

    current_tracers.push_back({
        .miss = synchronization.hit_type == 0 || synchronization.hit_type == 3,
        .origin = synchronization.origin,
        .target = synchronization.hit,
        .time = std::chrono::steady_clock::now()
    });

    return true;
}

auto plugin::cheats::tracers::on_event(const samp::event_info& event) -> bool {
    if (event == samp::event_type::incoming_packet && event == samp::event_id::bullet_synchronization)
        return on_bullet_synchronization(event.create<samp::event_id::bullet_synchronization, samp::event_type::incoming_packet>());

    return true;
}

auto plugin::cheats::tracers::render(types::not_null<gui_initializer*> child) -> void {
    if (current_tracers.empty() || game::is_menu_opened())
        return;

    auto cheat_configuration = (*configuration)["cheats"]["tracers"];
    auto time_to_hide = std::chrono::seconds(cheat_configuration["seconds_to_hide"]);
    ImDrawList* draw_list = ImGui::GetBackgroundDrawList();

    for (auto it = current_tracers.begin(); it != current_tracers.end();) {
        if (std::chrono::steady_clock::now() - it->time >= time_to_hide) {
            it = current_tracers.erase(it);
            continue;
        }

        auto [ origin_screen_x, origin_screen_y, origin_screen_z ] = game::convert_3d_coords_to_screen(it->origin);
        auto [ target_screen_x, target_screen_y, target_screen_z ] = game::convert_3d_coords_to_screen(it->target);

        if (origin_screen_z <= 0.0f || target_screen_z <= 0.0f) {
            it++;
            continue;
        }

        types::color color = (it->miss)
            ? gui::style::get_current_accent_colors().red
            : gui::style::get_current_accent_colors().green;

        draw_list->AddLine({ origin_screen_x, origin_screen_y }, { target_screen_x, target_screen_y }, *color, 1);
        draw_list->AddCircleFilled({ target_screen_x + 1.5f, target_screen_y + 1.5f }, 3, *color, 16);

        it++;
    } 
}

auto plugin::cheats::tracers::register_hotkeys(types::not_null<gui::hotkey_handler*> handler) -> void {
    handler->add(hotkey);
}

plugin::cheats::tracers::tracers() {
    hotkey = gui::hotkey("Удалить трассера", gui::key_bind({ 'C', 0 }, { .alt = true }, gui::bind_condition::on_alogin))
        .with_callback(std::bind(&tracers::hotkey_callback, this, std::placeholders::_1));
}
