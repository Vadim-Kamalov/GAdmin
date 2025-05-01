#include "plugin/cheats/clickwarp.h"
#include "plugin/game/camera.h"
#include "plugin/game/game.h"
#include "plugin/game/ped.h"
#include "plugin/game/vehicle.h"
#include "plugin/game/world.h"
#include "plugin/server/spectator.h"
#include "plugin/server/user.h"
#include "plugin/plugin.h"
#include "plugin/types/color.h"
#include "plugin/game/cursor.h"
#include <sstream>

void
plugin::cheats::clickwarp::stop_selecting_place() {
    selecting_place_to_warp = false;
    teleport_information = {};
}

void
plugin::cheats::clickwarp::on_alogin_new_state(bool state) {
    if (state || !selecting_place_to_warp)
        return;

    stop_selecting_place();
}

bool
plugin::cheats::clickwarp::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) {
    auto cheat_configuration = (*configuration)["cheats"]["clickwarp"];

    if (!cheat_configuration["use"] || !server::user::is_on_alogin() || server::spectator::is_active())
       return true;

    switch (message) {
        case WM_MBUTTONDOWN:
            game::cursor::set_status(true);
            selecting_place_to_warp = true;
            return false;

        case WM_LBUTTONDOWN: {
            if (!selecting_place_to_warp || !teleport_information.has_value())
                break;

            game::ped player_ped = game::ped::get_player();
            game::vehicle player_vehicle = player_ped.get_vehicle();

            // We need this cast to use default method from it.
            game::entity common_entity = (player_vehicle)
                ? static_cast<game::entity>(player_vehicle)
                : player_ped;

            if (teleport_information->vehicle_to_jump)
                player_ped.jump_into_vehicle(teleport_information->vehicle_to_jump);
            else 
                common_entity.teleport(teleport_information->coordinates);

            stop_selecting_place();
            game::cursor::set_status(false);

            return false;
        }
    }

    return true;
}

void
plugin::cheats::clickwarp::render(types::not_null<gui_initializer*> child) {
    if (!selecting_place_to_warp)
        return;

    if (!child->is_cursor_active()) {
        stop_selecting_place();
        return;
    }

    auto [ size_x, size_y ] = game::get_screen_resolution();
    auto [ cursor_x, cursor_y ] = ImGui::GetMousePos();

    if (cursor_x < 0 || cursor_y < 0 || cursor_x >= size_x || cursor_y >= size_y)
        return;

    types::vector_3d pos = game::camera::screen_to_coordinates(cursor_x, cursor_y, 700.0f);
    types::vector_3d cam = game::camera::get_active_coordinates();
    
    types::options<game::world::line_of_sight_condition> conditions = {
        game::world::line_of_sight_condition::buildings,
        game::world::line_of_sight_condition::vehicles,
        game::world::line_of_sight_condition::objects
    };
    
    auto line_of_sight = game::world::process_line_of_sight(cam, pos, conditions);

    if (!line_of_sight.has_value() || !line_of_sight->entity)
        return;

    types::vector_3d pos_diff = line_of_sight->pos - line_of_sight->normal * 0.1f;
    
    auto line_of_sight_second = game::world::process_line_of_sight(
        { pos_diff.x, pos_diff.y, pos_diff.z + ((line_of_sight->normal.z >= 0.5f) ? 1.0f : 300.0f) },
        { pos_diff.x, pos_diff.y, pos_diff.z - 0.3f },
        conditions);

    if (!line_of_sight_second.has_value())
        return;

    pos_diff = line_of_sight_second->pos;
    pos_diff.z++;

    game::ped player_ped = game::ped::get_player();
    game::vehicle vehicle = line_of_sight->entity.get_vehicle();

    teleport_information = teleport_information_t { pos_diff, game::vehicle(0) };
    
    ImFont* font = (*child->fonts->bold)[18];
    ImDrawList* draw_list = ImGui::GetBackgroundDrawList();

    std::string text = std::format("{:0.2f}m", player_ped.get_position().get_distance_to(pos_diff));
    ImVec2 distance_text_size = font->CalcTextSizeA(font->FontSize, FLT_MAX, 0.0f, text.c_str());
    types::color color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Text]);

    if (vehicle && !vehicle.has_driver() && !player_ped.get_vehicle()) {
        if (ImGui::IsMouseDown(ImGuiMouseButton_Right)) {
            teleport_information->vehicle_to_jump = vehicle;
            color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_TextDisabled]);
        }

        std::format_to(std::back_inserter(text), " ({})\nУдерживайте ПКМ чтобы занять руль",
                       game::get_vehicle_name(vehicle.get_model_index()));
    }

    ImVec2 text_pos = { cursor_x + distance_text_size.x / 2.0f, cursor_y + distance_text_size.y };
    {
        std::stringstream stream(text);
        for (std::string line; std::getline(stream, line);) {
            ImVec2 text_size = font->CalcTextSizeA(font->FontSize, FLT_MAX, 0.0f, line.c_str());

            draw_list->AddText(font, font->FontSize, { text_pos.x - text_size.x / 2, text_pos.y },
                               *color, line.c_str());

            text_pos.y += text_size.y + ImGui::GetStyle().ItemSpacing.y;
        }
    }
}
