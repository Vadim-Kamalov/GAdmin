#include "plugin/gui/windows/interaction_area.h"
#include "plugin/game/game.h"
#include "plugin/game/vehicle.h"
#include "plugin/plugin.h"
#include "plugin/samp/core/input.h"
#include "plugin/samp/core/user.h"
#include "plugin/samp/core/vehicle_pool.h"
#include "plugin/samp/player.h"
#include "plugin/server/spectator.h"
#include "plugin/server/user.h"
#include "plugin/types/color.h"
#include <cmath>
#include <ranges>
#include <utility>

auto plugin::gui::windows::interaction_area::get_distance_between_points(float ax, float ay, float bx, float by) const -> float {
    return std::hypot(bx - ax, by - ay);
}

auto plugin::gui::windows::interaction_area::find_player_nearby_to_screen_center(float radius) const
    -> std::optional<search_result>
{
    auto [ size_x, size_y ] = game::get_screen_resolution();
    std::optional<search_result> result;

    for (const auto& [ player, ped ] : samp::player::get_stream_players()) {
        if (player.id == samp::user::get_id() || (server::spectator::is_active() && player.id == server::spectator::id))
            continue;

        game::ped game_ped = ped.get_game_ped();

        if (!game_ped || !game_ped.is_on_screen())
            continue;

        types::vector_3d position = game_ped.get_bone_bosition(game::ped::bone::head);
        types::vector_3d screen_point = game::convert_3d_coords_to_screen(position);

        if (screen_point.z <= 0.0f)
            continue;

        float distance = get_distance_between_points(size_x / 2.0f, size_y / 2.0f,
                                                     screen_point.x, screen_point.y);
    
        if (radius <= distance)
            continue;

        if (!result.has_value() || distance < result->distance) {
            result = search_result {
                .point = { screen_point.x, screen_point.y },
                .distance = distance,
                .id = player.id,
                .description = std::format("{}[{}]", player.nickname, player.id)
            };
        }
    }

    return result;
}

auto plugin::gui::windows::interaction_area::find_vehicle_nearby_to_screen_center(float radius) const
    -> std::optional<search_result>
{
    auto [size_x, size_y] = game::get_screen_resolution();
    float center_x = size_x / 2.0f, center_y = size_y / 2.0f;
    std::optional<search_result> result;

    game::vehicle player_vehicle = game::ped::get_player().get_vehicle();

    for (std::uint16_t id = 0; id < samp::vehicle_pool::max_vehicles; id++) {
        auto vehicle = samp::vehicle_pool::get_vehicle(id);
        
        if (!vehicle)
            continue;

        game::vehicle game_vehicle = vehicle->get_game_vehicle();
        
        if (!game_vehicle || !game_vehicle.is_on_screen() || (player_vehicle && game_vehicle == player_vehicle))
            continue;

        types::vector_3d screen_point = game::convert_3d_coords_to_screen(game_vehicle.get_position());
        
        if (screen_point.z <= 0.0f)
            continue;

        float distance = get_distance_between_points(center_x, center_y, screen_point.x, screen_point.y);
        
        if (distance > radius)
            continue;

        if (!result || distance < result->distance) {
            result = search_result {
                .point = { screen_point.x, screen_point.y },
                .distance = distance,
                .id = id,
                .description = std::format("{} ({})", game::get_vehicle_name(game_vehicle.get_model_index()), id)
            };
        }
    }

    return result;
}

auto plugin::gui::windows::interaction_area::search_from_screen_center(float radius) const
    -> std::optional<search_result>
{
    switch (current_search_type) {
        case search_type::players:
            return find_player_nearby_to_screen_center(radius);
        case search_type::vehicles:
            return find_vehicle_nearby_to_screen_center(radius);
    }

    return {};
}

auto plugin::gui::windows::interaction_area::handle_controls() -> void {
    if (ImGui::IsKeyReleased(ImGuiKey_1))
        current_search_type = (current_search_type == search_type::vehicles)
            ? search_type::players : search_type::vehicles;

    for (int action_id = 0; action_id < action_count_per_type; action_id++) {
        if (ImGui::IsKeyReleased(static_cast<ImGuiKey>(ImGuiKey_2 + action_id))) {
            std::uint8_t response_offset = (current_search_type == search_type::vehicles)
                ? response_vehicle_offset : response_player_offset;
        
            current_search_response = static_cast<search_response>(action_id + response_offset);

            return;
        }
    }
}

auto plugin::gui::windows::interaction_area::handle_search_response(std::uint16_t id) -> void {
    std::string command = "";

#define FINISH_CASE(COMMAND, POSTFIX) command = std::format(COMMAND " {}" POSTFIX, id); break
    switch (current_search_response) {
        case search_response::player_spectate: FINISH_CASE("sp", "");
        case search_response::player_heal: FINISH_CASE("aheal", "");
        case search_response::player_stats: FINISH_CASE("stats", "");
        case search_response::player_pame: FINISH_CASE("pame", "");
        case search_response::player_gethere: FINISH_CASE("gethere", "");
        case search_response::vehicle_repair: FINISH_CASE("vrepair", "");
        case search_response::vehicle_spawn: FINISH_CASE("vspawn", "");
        case search_response::vehicle_fuel: FINISH_CASE("vfuel", " 90");
        case search_response::vehicle_id: FINISH_CASE("adm_vehid", "");
        case search_response::vehicle_gethere: FINISH_CASE("getcar", "");
        case search_response::none: std::unreachable();
    }
#undef FINISH_CASE

    samp::input::send_command("/{}", command);
    current_search_response = search_response::none;
}

auto plugin::gui::windows::interaction_area::render_stroked_text(ImDrawList* draw_list, ImFont* font, const ImVec2& pos,
                                                                 const types::color& color, types::zstring_t text) const
    -> void
{
    draw_list->AddText(font, font->FontSize, { pos.x + 1, pos.y + 1 }, 0xFF000000, text);
    draw_list->AddText(font, font->FontSize, { pos.x - 1, pos.y - 1 }, 0xFF000000, text);
    draw_list->AddText(font, font->FontSize, { pos.x + 1, pos.y - 1 }, 0xFF000000, text);
    draw_list->AddText(font, font->FontSize, { pos.x - 1, pos.y + 1 }, 0xFF000000, text);
    draw_list->AddText(font, font->FontSize, pos, *color, text);
}

auto plugin::gui::windows::interaction_area::render_help_text(ImDrawList* draw_list, float radius, const types::color& active_color,
                                                              const types::color& disabled_color) const -> void
{
    auto [ size_x, size_y ] = game::get_screen_resolution();

    ImVec2 center = { size_x / 2.0f, size_y / 2.0f };
    ImVec2 spacing = ImGui::GetStyle().ItemSpacing;
    ImVec2 longest_description_size = bold_font->CalcTextSizeA(bold_font->FontSize, FLT_MAX, 0.0f, get_longest_action_description());

    float group_size = std::size(actions_description) / 2.0f + 1;
    float group_height = (bold_font->FontSize * (group_size + spacing.y)) - spacing.y;

    for (const auto& [ group_index, group ] : actions_description | std::views::enumerate) {
        types::color color = (std::to_underlying(current_search_type) == group_index)
            ? active_color : disabled_color;
        
        for (const auto& [ index, description ] : group | std::views::enumerate) {
            ImVec2 size = bold_font->CalcTextSizeA(bold_font->FontSize, FLT_MAX, 0.0f, description);
            float y = center.y - (group_height / 2) + ((index - 1) * 20);
            float x = center.x + ((group_index == 0) 
                    ? -radius - 20 - longest_description_size.x
                    : radius + 20 + (longest_description_size.x - size.x));

            render_stroked_text(draw_list, bold_font, { x, y }, color, description);
        }
    }
}

auto plugin::gui::windows::interaction_area::render_search_description(ImDrawList* draw_list, float radius, const types::color& active_color,
                                                                       const std::string& search_description) const -> void
{
    std::array<std::string, 2> lines = { "1 - переключение между режимами (поиск игроков или машин)",
                                         search_description };

    auto [ size_x, size_y ] = game::get_screen_resolution();
    ImVec2 center = { size_x / 2.0f, size_y / 2.0f };

    for (const auto& [ index, line ] : lines | std::views::enumerate) {
        ImFont* font = (index == 0) ? regular_font : bold_font;
        float x = center.x - font->CalcTextSizeA(font->FontSize, FLT_MAX, 0.0f, line.c_str()).x / 2;
        float y = center.y + ((index == 0) ? radius + 20 : -radius - 30);

        render_stroked_text(draw_list, font, { x, y }, active_color, line.c_str());
    }
}

auto plugin::gui::windows::interaction_area::render() -> void {
    auto window_configuration = (*configuration)["windows"]["interaction_area"];

    if (!window_configuration["use"] || !server::user::is_on_alogin() ||
        !child->hotkey_handler->is_hotkey_active(activation_hotkey))
    {
        return;
    }

    handle_controls();

    float radius = window_configuration["radius"];
    ImDrawList* draw_list = ImGui::GetBackgroundDrawList();

    auto [ size_x, size_y ] = game::get_screen_resolution();
    ImVec2 center = { size_x / 2.0f, size_y / 2.0f };
    
    types::color color_active = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Text]);
    types::color color_disabled = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_TextDisabled]);
    std::string search_description = "";

    draw_list->AddCircle(center, radius, *color_active, 64, 2);
    
    if (auto search_result = search_from_screen_center(radius)) {
        if (current_search_response != search_response::none)
            handle_search_response(search_result->id);
        
        draw_list->AddLine(center, search_result->point, *color_active, 2);
    
        search_description = search_result->description;
    }

    render_search_description(draw_list, radius, color_active, search_description);
    render_help_text(draw_list, radius, color_active, color_disabled);
}

auto plugin::gui::windows::interaction_area::create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t {
    return std::make_unique<interaction_area>(child);
}

plugin::gui::windows::interaction_area::interaction_area(types::not_null<gui_initializer*> child)
    : window(child),
      bold_font((*child->fonts->bold)[18]),
      regular_font((*child->fonts->regular)[18])
{
    activation_hotkey = hotkey("Активация кругового меню", key_bind({ 'Z', 0 }, bind_condition::on_alogin));
    child->hotkey_handler->add(activation_hotkey);
}
