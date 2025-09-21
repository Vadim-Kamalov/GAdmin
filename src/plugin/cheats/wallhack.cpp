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

#include "plugin/cheats/wallhack.h"
#include "plugin/samp/core/net_game.h"
#include "plugin/gui/icon.h"
#include "plugin/gui/notify.h"
#include "plugin/samp/player.h"
#include "plugin/server/user.h"
#include "plugin/game/game.h"
#include "plugin/plugin.h"

auto plugin::cheats::wallhack::set_wallhack_state(bool state) -> void {
    if (cheat_active == state)
        return;
    
    auto& cheat_configuration = (*configuration)["cheats"]["wallhack"];
    
    if (!cheat_configuration["use"])
        return;
    
    cheat_active = state;

    if (cheat_configuration["custom_render"])
        return;

    set_samp_render_state(!state, false);
}

auto plugin::cheats::wallhack::hotkey_callback(gui::hotkey& hotkey) -> void {
    if (!server::user::is_on_alogin())
        return;

    samp::net_game::get_server_settings().set_name_tags_render_state(cheat_active);
    set_wallhack_state(!cheat_active);

    std::string notify_title = "WallHack " + std::string((cheat_active) ? "включен" : "выключен");
    std::string notify_description = std::format("Теперь вы {}можете видеть никнеймы сквозь стены. Переключить обратно - {}",
                                                 ((cheat_active) ? "" : "не "), hotkey.bind);

    gui::notify::send(gui::notification(notify_title, notify_description, ICON_INFO));
}

auto plugin::cheats::wallhack::set_samp_render_state(bool state, bool ensure_usage_valid) noexcept -> void {
    if (ensure_usage_valid && !server::user::is_on_alogin() && !(*configuration)["cheats"]["wallhack"]["use"])
        return;

    samp::server_settings settings = samp::net_game::get_server_settings();
    settings.set_name_tags_render_behind_wall(state);
    settings.set_name_tags_render_distance((state) ? SERVER_NAME_TAGS_DISTANCE : render_distance);
}

auto plugin::cheats::wallhack::register_hotkeys(types::not_null<gui::hotkey_handler*> handler) -> void {
    handler->add(hotkey);
}

auto plugin::cheats::wallhack::render(types::not_null<gui_initializer*> child) -> void {
    auto& cheat_configuration = (*configuration)["cheats"]["wallhack"];

    if (!cheat_configuration["use"]) {
        samp::net_game::get_server_settings().set_name_tags_render_state(true);
        set_wallhack_state(false);
        return;
    }

    if (!cheat_active || !cheat_configuration["custom_render"] || game::is_menu_opened())
        return;

    float font_size = cheat_configuration["font_size"];
    ImDrawList* draw_list = ImGui::GetBackgroundDrawList();
    ImFont* font = child->fonts->bold;

    samp::net_game::get_server_settings().set_name_tags_render_state(false);

    for (const auto& [ player, ped ] : samp::player::get_stream_players()) {
        game::ped game_ped = ped.get_game_ped();

        if (!game_ped.is_on_screen())
            continue;

        std::string text = std::format("{}[{}]", player.nickname, player.id);
        types::vector_3d bone_position = game_ped.get_bone_bosition(game::ped::bone::head);
        types::color color = player.get_color();
       
        if (color == 0 || color == 0xFFFFFFFF)
            color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Text]);

        auto [ pos_x, pos_y, pos_z ] = game::convert_3d_coords_to_screen(bone_position);
        
        if (pos_z <= 0.0f)
            continue;

        pos_x -= font->CalcTextSizeA(font_size, FLT_MAX, 0.0f, text.c_str()).x / 2;

        draw_list->AddText(font, font_size, { pos_x + 1, pos_y + 1 }, 0xFF000000, text.c_str());
        draw_list->AddText(font, font_size, { pos_x - 1, pos_y - 1 }, 0xFF000000, text.c_str());
        draw_list->AddText(font, font_size, { pos_x + 1, pos_y - 1 }, 0xFF000000, text.c_str());
        draw_list->AddText(font, font_size, { pos_x - 1, pos_y + 1 }, 0xFF000000, text.c_str());
        draw_list->AddText(font, font_size, { pos_x, pos_y }, *color, text.c_str());
    }
}

auto plugin::cheats::wallhack::on_alogin_new_state(bool state) -> void {
    set_wallhack_state(state);
}

plugin::cheats::wallhack::wallhack() {
    hotkey = gui::hotkey("Переключить WallHack", gui::key_bind({ 'X', 0 }, { .alt = true }, gui::bind_condition::on_alogin))
        .with_callback(std::bind(&wallhack::hotkey_callback, this, std::placeholders::_1));
}
