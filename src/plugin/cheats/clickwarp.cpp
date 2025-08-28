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

auto plugin::cheats::clickwarp::stop_selecting_place() -> void {
    selecting_place_to_warp = false;
    teleport_information = {};
}

auto plugin::cheats::clickwarp::on_alogin_new_state(bool state) -> void {
    if (state || !selecting_place_to_warp)
        return;

    stop_selecting_place();
}

auto plugin::cheats::clickwarp::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool {
    bool use = (*configuration)["cheats"]["clickwarp"];

    if (!use || !server::user::is_on_alogin() || server::spectator::is_active())
       return true;

    switch (message) {
        case WM_MBUTTONDOWN:
            game::cursor::set_state(true);
            selecting_place_to_warp = true;
            return false;

        case WM_LBUTTONDOWN: {
            if (!selecting_place_to_warp || !teleport_information.has_value())
                break;

            game::ped player_ped = game::ped::get_player();
            game::vehicle player_vehicle = player_ped.get_vehicle();

            if (teleport_information->vehicle_to_jump)
                player_ped.jump_into_vehicle(teleport_information->vehicle_to_jump);
            else {
                // `game::ped` and `game::vehicle` offer two different implementations for the teleportation
                // method, which we don't want to use because we only need to teleport an entity without
                // any additional details, e.g., applying specific flags for `game::ped`.
                game::entity common_entity = (player_vehicle)
                    ? static_cast<game::entity>(player_vehicle)
                    : player_ped;

                common_entity.teleport(teleport_information->coordinates);
            }

            stop_selecting_place();
            game::cursor::set_state(false);

            return false;
        }
    }

    return true;
}

auto plugin::cheats::clickwarp::render(types::not_null<gui_initializer*> child) -> void {
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
    
    ImFont* font = child->fonts->bold;
    ImDrawList* draw_list = ImGui::GetBackgroundDrawList();

    std::string text = std::format("{:0.2f}m", player_ped.get_position().get_distance_to(pos_diff));
    ImVec2 distance_text_size = font->CalcTextSizeA(font_size, FLT_MAX, 0.0f, text.c_str());
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
            ImVec2 text_size = font->CalcTextSizeA(font_size, FLT_MAX, 0.0f, line.c_str());

            draw_list->AddText(font, font_size, { text_pos.x - text_size.x / 2, text_pos.y },
                               *color, line.c_str());

            text_pos.y += text_size.y + ImGui::GetStyle().ItemSpacing.y;
        }
    }
}
