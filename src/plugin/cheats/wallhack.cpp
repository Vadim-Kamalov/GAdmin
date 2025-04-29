#include "plugin/cheats/wallhack.h"
#include "plugin/samp/core/net_game.h"
#include "plugin/gui/notify.h"
#include "plugin/samp/player.h"
#include "plugin/server/user.h"
#include "plugin/game/game.h"
#include "plugin/plugin.h"

void
plugin::cheats::wallhack::set_wallhack_state(bool state) {
    auto cheat_configuration = (*configuration)["cheats"]["wallhack"];
    
    if (!cheat_configuration["use"])
        return;

    if (cheat_active == state)
        return;
    
    cheat_active = state;

    if (cheat_configuration["custom_render"])
        return;

    samp::server_settings settings = samp::net_game::get_server_settings();
    settings.set_name_tags_render_behind_wall(!state);
    settings.set_name_tags_render_distance((state) ? render_distance : SERVER_NAME_TAGS_DISTANCE);
}

void
plugin::cheats::wallhack::hotkey_callback(gui::hotkey& hotkey) {
    if (!server::user::is_on_alogin())
        return;

    set_wallhack_state(!cheat_active);

    std::string notify_title = "WallHack " + std::string((cheat_active) ? "включен" : "выключен");
    std::string notify_description = std::format("Теперь вы {}можете видеть никнеймы сквозь стены. Переключить обратно - {}",
                                                 ((cheat_active) ? "" : "не "), hotkey.bind);

    gui::notify::send(gui::notification(notify_title, notify_description, ICON_INFO));
}

void
plugin::cheats::wallhack::register_hotkeys(types::not_null<gui::hotkey_handler*> handler) {
    handler->add(hotkey);
}

void
plugin::cheats::wallhack::render(types::not_null<gui_initializer*> child) {
    auto cheat_configuration = (*configuration)["cheats"]["wallhack"];

    if (!cheat_active || !cheat_configuration["custom_render"])
        return;

    float font_size = cheat_configuration["font_size"];
    ImDrawList* draw_list = ImGui::GetBackgroundDrawList();
    ImFont* font = (*child->fonts->bold)[18];

    for (const auto& [ player, ped ] : samp::player::get_stream_players()) {
        game::ped game_ped = ped.get_game_ped();

        if (!game_ped.is_on_screen())
            continue;

        std::string text = std::format("{}[{}]", player.nickname, player.id);
        types::vector_3d bone_position = game_ped.get_bone_bosition(game::ped::bone::head);
        types::color color = player.get_color();
       
        if (color == 0 || color == 0xFFFFFFFF)
            color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Text]);

        auto [ pos_x, pos_y ] = game::convert_3d_coords_to_screen(bone_position);
        pos_x -= font->CalcTextSizeA(font_size, FLT_MAX, 0.0f, text.c_str()).x / 2;

        draw_list->AddText(font, font_size, { pos_x + 1, pos_y + 1 }, 0xFF000000, text.c_str());
        draw_list->AddText(font, font_size, { pos_x - 1, pos_y - 1 }, 0xFF000000, text.c_str());
        draw_list->AddText(font, font_size, { pos_x + 1, pos_y - 1 }, 0xFF000000, text.c_str());
        draw_list->AddText(font, font_size, { pos_x - 1, pos_y + 1 }, 0xFF000000, text.c_str());
        draw_list->AddText(font, font_size, { pos_x, pos_y }, *color, text.c_str());
    }
}

void
plugin::cheats::wallhack::on_alogin_new_state(bool state) {
    set_wallhack_state(state);
}

plugin::cheats::wallhack::wallhack() {
    hotkey = gui::hotkey("Переключить WallHack", gui::key_bind({ 'X', 0 }, { .alt = true }, gui::bind_condition::on_alogin))
        .with_callback(std::bind(&wallhack::hotkey_callback, this, std::placeholders::_1));
}
