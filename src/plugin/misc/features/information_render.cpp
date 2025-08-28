#include "plugin/misc/features/information_render.h"
#include "plugin/gui/style.h"
#include "plugin/samp/core/vehicle_pool.h"
#include "plugin/samp/player.h"
#include "plugin/game/vehicle.h"
#include "plugin/game/game.h"
#include "plugin/server/admins.h"
#include "plugin/server/user.h"
#include "plugin/plugin.h"

auto plugin::misc::features::information_render::render_cars_information(ImDrawList* draw_list, ImFont* bold_font,
                                                                         ImFont* regular_font, float font_size) const -> void
{
    game::ped player_ped = game::ped::get_player();
    game::vehicle player_vehicle = player_ped.get_vehicle();

    for (const auto& [ id, vehicle ] : samp::vehicle_pool::get_stream()) {
        game::vehicle game_vehicle = vehicle.get_game_vehicle();

        if (!game_vehicle || !game_vehicle.is_on_screen() || game_vehicle == player_vehicle)
            continue;

        types::vector_3d vehicle_position = game_vehicle.get_position();    
        types::vector_3d player_position = player_ped.get_position();

        if (vehicle_position.get_distance_to(player_position) >= 50.0f)
            continue;

        auto [ pos_x, pos_y, pos_z ] = game::convert_3d_coords_to_screen(vehicle_position);
    
        if (pos_z <= 0.0f)
            continue;

        bool vehicle_locked = vehicle.is_locked();
        bool engine_active = vehicle.is_engine_active();
        types::color default_color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Text]);
        types::color state_color[2] = { gui::style::get_current_accent_colors().green, gui::style::get_current_accent_colors().red, };

        std::deque<text_object> objects_on_first_line = {
            { "HP: ", default_color, bold_font },
            { std::to_string(static_cast<int>(game_vehicle.get_health())), state_color[0], regular_font },
            { " · ", default_color, bold_font },
            { (vehicle_locked) ? "Closed" : "Opened", state_color[vehicle_locked], regular_font },
            { " · ", default_color, bold_font },
            { (engine_active) ? "On" : "Off", state_color[!engine_active], regular_font }
        };

        ImVec2 first_line_pos = { pos_x, pos_y };
        float second_line_offset_y = 0;

        for (const auto& object : objects_on_first_line) {
            ImVec2 text_size = object.font->CalcTextSizeA(font_size, FLT_MAX, 0.0f, object.text.c_str());

            draw_list->AddText(object.font, font_size, first_line_pos, *object.color, object.text.c_str());
        
            first_line_pos.x += text_size.x;
            second_line_offset_y = text_size.y;
        }

        std::string second_line_text = std::format("{} ({})", game::get_vehicle_name(vehicle.get_model_index()), id);

        draw_list->AddText(bold_font, font_size, { pos_x, pos_y + second_line_offset_y },
                           *default_color, second_line_text.c_str());
    }
}

auto plugin::misc::features::information_render::on_samp_initialize() -> void {
    samp_initialized = true;
}

auto plugin::misc::features::information_render::render(types::not_null<gui_initializer*> child) -> void {
    if (!samp_initialized || !server::user::is_on_alogin() || game::is_menu_opened())
        return;

    auto features_configuration = (*configuration)["misc"];

    feature_configuration gun_configuration = features_configuration["gun_info"];
    feature_configuration car_configuration = features_configuration["car_info"];
    feature_configuration admin_configuration = features_configuration["admin_info"];

    if (!gun_configuration.use && !car_configuration.use && !admin_configuration.use)
        return;

    float item_spacing_y = ImGui::GetStyle().ItemSpacing.y;
    ImDrawList* draw_list = ImGui::GetBackgroundDrawList();
    ImFont* font = child->fonts->regular;

    if (car_configuration.use)
        render_cars_information(draw_list, child->fonts->bold, font, car_configuration.font_size);

    for (const auto& [ player, ped ] : samp::player::get_stream_players()) {
        game::ped game_ped = ped.get_game_ped();
        
        if (!game_ped || !game_ped.is_on_screen())
            continue;

        types::vector_3d bone_position = game_ped.get_bone_bosition(game::ped::bone::torso);
        auto [ pos_x, pos_y, pos_z ] = game::convert_3d_coords_to_screen(bone_position);

        if (pos_z <= 0.0f)
            continue;

        float y_offset = 0;

        if (gun_configuration.use) {
            std::string text = game::weapon_names[std::to_underlying(ped.get_current_weapon())];
            ImU32 text_color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Text]);
            ImVec2 text_size = font->CalcTextSizeA(gun_configuration.font_size, FLT_MAX, 0.0f, text.c_str());
            ImVec2 pos = { pos_x - text_size.x / 2, pos_y };

            draw_list->AddText(font, gun_configuration.font_size, pos, text_color, text.c_str());

            y_offset += text_size.y + item_spacing_y;
        }

        if (admin_configuration.use) {
            auto admin = server::admins::get_admin(player.id);
        
            if (!admin.has_value())
                continue;

            types::color text_color = *gui::style::get_current_accent_colors().red;
            ImVec2 text_size = font->CalcTextSizeA(admin_configuration.font_size, FLT_MAX, 0.0f, admin->nickname.c_str());
            ImVec2 pos = { pos_x - text_size.x / 2, pos_y + y_offset };

            draw_list->AddText(font, admin_configuration.font_size, pos, *text_color, admin->nickname.c_str());
        }
    }
}
