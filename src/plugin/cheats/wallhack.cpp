/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2024-2026 The Contributors.
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

auto plugin::cheats::wallhack::enable() -> void {
    cheat_active = true;
    update();
}

auto plugin::cheats::wallhack::disable() -> void {
    cheat_active = false;
    update();
}

auto plugin::cheats::wallhack::toggle(bool when) -> void {
    if (when)
        enable();
    else
        disable();
}

auto plugin::cheats::wallhack::update() -> void {
    auto& cheat_configuration = (*configuration)["cheats"]["wallhack"];
    auto server_settings = samp::net_game::get_server_settings();

    if (cheat_configuration["custom_render"]) {
        server_settings.set_name_tags_render_state(!cheat_active);

        if (server_settings.get_name_tags_render_distance() == max_render_distance) {
            server_settings.set_name_tags_render_behind_wall(false);
            server_settings.set_name_tags_render_distance(SERVER_NAME_TAGS_DISTANCE);
        }

        return;
    }

    server_settings.set_name_tags_render_state(true);
    server_settings.set_name_tags_render_behind_wall(!cheat_active);
    server_settings.set_name_tags_render_distance((cheat_active) ? max_render_distance : SERVER_NAME_TAGS_DISTANCE);
}

auto plugin::cheats::wallhack::hotkey_callback(gui::hotkey& hotkey) -> void {
    using namespace gui;

    if (!(*configuration)["cheats"]["wallhack"]["use"] || !server::user::is_on_alogin())
        return;
    
    toggle(!cheat_active);

    std::string notify_title = "WallHack " + std::string((cheat_active) ? "включен" : "выключен");
    std::string notify_description = std::format("Теперь вы {}можете видеть никнеймы сквозь стены. Переключить обратно - {}",
                                                 ((cheat_active) ? "" : "не "), hotkey.bind);

    notify::send(notification(notify_title, notify_description, ICON_INFO));
}

auto plugin::cheats::wallhack::render_custom_name_tag(const name_tag_settings_t& settings) const -> void {
    auto [ pos_x, pos_y, pos_z ] =
        game::convert_3d_coords_to_screen(settings.ped.get_bone_bosition(game::ped::bone::head));

    if (pos_z <= 0.0f)
        return;

    std::string text = std::format("{}[{}]", settings.player.nickname, settings.player.id);

    if (settings.player.is_paused())
        text.append(" (AFK)");

    pos_x -= settings.font->CalcTextSizeA(settings.font_size, FLT_MAX, 0.0f, text.c_str()).x / 2;    
    settings.draw_list->AddText(settings.font, settings.font_size, { pos_x + 1, pos_y + 1 }, 0xFF000000, text.c_str());
    settings.draw_list->AddText(settings.font, settings.font_size, { pos_x - 1, pos_y - 1 }, 0xFF000000, text.c_str());
    settings.draw_list->AddText(settings.font, settings.font_size, { pos_x + 1, pos_y - 1 }, 0xFF000000, text.c_str());
    settings.draw_list->AddText(settings.font, settings.font_size, { pos_x - 1, pos_y + 1 }, 0xFF000000, text.c_str());
    settings.draw_list->AddText(settings.font, settings.font_size, { pos_x, pos_y }, *settings.color, text.c_str());
}

auto plugin::cheats::wallhack::render_bones(const bones_settings_t& settings) const -> void {
    using bone = game::ped::bone;

    static auto bones_to_render = std::to_array<std::pair<bone, bone>>({
        /// Head.
        std::make_pair(bone::head, bone::neck),

        /// Right hand.
        std::make_pair(bone::neck, bone::right_hand_shoulder),
        std::make_pair(bone::right_hand_shoulder, bone::right_hand_elbow),
        std::make_pair(bone::right_hand_elbow, bone::right_hand_palm),
        std::make_pair(bone::right_hand_palm, bone::right_hand_middle_finger),

        /// Left hand.
        std::make_pair(bone::neck, bone::left_hand_shoulder),
        std::make_pair(bone::left_hand_shoulder, bone::left_hand_elbow),
        std::make_pair(bone::left_hand_elbow, bone::left_hand_palm),
        std::make_pair(bone::left_hand_palm, bone::left_hand_middle_finger),

        /// Nech-torso-stomach.
        std::make_pair(bone::neck, bone::torso),
        std::make_pair(bone::torso, bone::stomach),

        /// Right leg.
        std::make_pair(bone::stomach, bone::right_leg_elbow),
        std::make_pair(bone::right_leg_elbow, bone::right_leg_ankle),

        /// Left leg.
        std::make_pair(bone::stomach, bone::left_leg_elbow),
        std::make_pair(bone::left_leg_elbow, bone::left_leg_ankle),
    }); // static auto bones_to_render = std::to_array<std::pair<bone, bone>({ ... })

    for (const auto& [ first_bone, second_bone ] : bones_to_render) {
        auto [ first_pos_x, first_pos_y, first_pos_z ] =
            game::convert_3d_coords_to_screen(settings.ped.get_bone_bosition(first_bone));
        
        if (first_pos_z <= 0.0f)
            continue;

        auto [ second_pos_x, second_pos_y, second_pos_z ] = 
            game::convert_3d_coords_to_screen(settings.ped.get_bone_bosition(second_bone));
        
        if (second_pos_z <= 0.0f)
            continue;

        settings.draw_list->AddLine({ first_pos_x, first_pos_y }, { second_pos_x, second_pos_y },
                                    *settings.color, settings.bone_width);
    }
}

auto plugin::cheats::wallhack::register_hotkeys(types::not_null<gui::hotkey_handler*> handler) -> void {
    handler->add(hotkey);
}

auto plugin::cheats::wallhack::render(types::not_null<gui_initializer*> child) -> void {
    auto& cheat_configuration = (*configuration)["cheats"]["wallhack"];
    bool custom_render = cheat_configuration["custom_render"];
    bool show_bones = cheat_configuration["show_bones"];

    if (!cheat_active || (!custom_render && !show_bones) || game::is_menu_opened())
        return;

    ImDrawList* draw_list = ImGui::GetBackgroundDrawList();
    ImFont* font = child->fonts->bold;

    float font_size = cheat_configuration["font_size"];
    float bone_width = cheat_configuration["bone_width"];

    if (custom_render)
        samp::net_game::get_server_settings().set_name_tags_render_state(false);

    for (const auto& [ player, ped ] : samp::player::get_stream_players()) {
        game::ped game_ped = ped.get_game_ped();

        if (!game_ped.is_on_screen())
            continue;

        types::color color = player.get_color();
       
        if (color == 0 || color == 0xFFFFFFFF)
            color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Text]);

        if (custom_render)
            render_custom_name_tag({ draw_list, font, font_size, color, player, game_ped });

        if (!show_bones)
            continue;

        render_bones({ draw_list, bone_width, color, game_ped });
    }
}

auto plugin::cheats::wallhack::on_alogin_new_state(bool state) -> void {
    toggle(state);
}

plugin::cheats::wallhack::wallhack() {
    hotkey = gui::hotkey("Переключить WallHack", gui::key_bind({ 'X', 0 }, { .alt = true }, gui::bind_condition::on_alogin))
        .with_callback(std::bind(&wallhack::hotkey_callback, this, std::placeholders::_1));
}
