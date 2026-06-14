/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2026 The Contributors.
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

#include "plugin/gui/windows/autocompletion.h"
#include "plugin/gui/windows/report/network.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/samp/core/input.h"
#include "plugin/samp/core/user.h"
#include "plugin/samp/core/player_pool.h"
#include "plugin/samp/core/vehicle_pool.h"
#include "plugin/game/vehicle.h"
#include "plugin/server/admins.h"
#include "plugin/types/string_iterator.h"
#include "plugin/server/spectator.h"
#include "plugin/string_utils.h"
#include "plugin/plugin.h"
#include "plugin/log.h"

static constexpr std::uint8_t settings_bytes[] = {

#ifdef USE_EMBEDDED_MESSAGE_PACK
#embed "../../../../embed/autocompletion.mpk"
#else
#embed "../../../../embed/autocompletion.json"
#endif // USE_EMBEDDED_MESSAGE_PACK

}; // static constexpr std::uint8_t settings_bytes[]

auto plugin::gui::windows::autocompletion::predefined_argument_id(std::vector<suggestion_t>& output) -> void {
    auto& player_checker = (*configuration)["windows"]["player_checker"];

    std::deque<player_argument_suggestion_t> suggestions;
    std::uint16_t user_id = samp::user::get_id();

    if (auto report = report::network::active_report)
        suggestions.emplace_back(report->id, report->nickname, "/reports");

    if (server::spectator::is_active())
        suggestions.emplace_back(server::spectator::id, server::spectator::nickname, "/sp");

    for (const auto& player : player_checker["players"]) {
        std::string nickname = player["nickname"];
        auto id = samp::player_pool::get_id(nickname);

        if (!id)
            continue;

        suggestions.emplace_back(*id, nickname, "чекер игроков");
    }

    for (const auto& admin : server::admins::list)
        if (auto ic_nickname = samp::player_pool::get_nickname(admin.id))
            suggestions.emplace_back(admin.id, *ic_nickname, admin.nickname);

    for (std::uint16_t id = 0; id <= SERVER_MAX_PLAYERS; id++) {
        auto nickname = samp::player_pool::get_nickname(id);

        if (!nickname)
            continue;

        suggestions.emplace_back(id, *nickname, "");
    }

    output.emplace_back(std::to_string(user_id), std::format("{} (ваш ID)", samp::user::get_name()));

    for (const auto& suggestion_info : suggestions) {
        if (suggestion_info.id == user_id)
            continue;

        std::string description = suggestion_info.nickname;

        if (!suggestion_info.description.empty())
            description.append(std::format(" ({})", suggestion_info.description));

        output.emplace_back(std::to_string(suggestion_info.id), description);
    }
}

auto plugin::gui::windows::autocompletion::predefined_argument_car_id(std::vector<suggestion_t>& output) -> void {
    for (const auto& [ id, vehicle ] : samp::vehicle_pool::get_stream()) {
        if (!vehicle.is_available())
            continue;

        std::uint16_t model_index = vehicle.get_model_index();
        std::string model_name = game::get_vehicle_name(model_index);

        output.emplace_back(std::to_string(id), std::format("{} (в радиусе прорисовки)", model_name));
    }
}

auto plugin::gui::windows::autocompletion::predefined_argument_mycar_id(std::vector<suggestion_t>& output) -> void {
    if (!server::spectator::is_active())
        return;

    auto spectator_information = server::spectator::get_information();
    std::stringstream stream(spectator_information.vehicle);

    for (std::string single_vehicle; std::getline(stream, single_vehicle, ' ');)
        output.emplace_back(single_vehicle, "Машина игрока в /sp");
}

auto plugin::gui::windows::autocompletion::get_suggestion_info_from_user_input() const 
    -> suggestion_info_t
{
    types::string_iterator iterator(current_input_text);

    if (!iterator.current().has_value() || iterator.consume() != '/')
        return std::monostate {};

    iterator.skip(::isspace);

    std::string command_name = "/" + iterator.collect_word();

    if (command_name.length() == 1 || !iterator.current().has_value())
        return command_info_t { command_name };

    const nlohmann::json& commands = settings["commands"];

    if (!commands.contains(command_name))
        return std::monostate {};

    const nlohmann::json& command = commands[command_name];
    std::size_t command_array_size = command.size();

    if (command_array_size == 1) // if it only contains a description
        return std::monostate {};

    std::string argument_value = "";
    std::size_t argument_index = 0;

    while (iterator.current().has_value()) {
        if (++argument_index == command_array_size)
            return std::monostate {};

        iterator.skip(::isspace);

        argument_value = iterator.collect_word();
    }

    return argument_info_t { argument_value, command[argument_index] };
}

auto plugin::gui::windows::autocompletion::get_suggestions() -> std::vector<suggestion_t> {
    suggestion_info_t suggestion_info = get_suggestion_info_from_user_input();

    if (std::holds_alternative<std::monostate>(suggestion_info))
        return {};
 
    std::vector<suggestion_t> suggestions;

    if (std::holds_alternative<argument_info_t>(suggestion_info)) {
        auto argument_info = std::get<argument_info_t>(suggestion_info);
        auto argument_suggestions = get_all_suggestions_for_argument(argument_info.name);
        auto user_input = string_utils::to_lowercase(argument_info.user_input);

        for (const auto& suggestion : argument_suggestions) {
            if (!suggestion.name.contains(user_input))
                continue;

            suggestions.push_back(suggestion);
        }

        return suggestions;
    }

    auto command_info = std::get<command_info_t>(suggestion_info);
    auto command_name = string_utils::to_lowercase(command_info.name);

    for (const auto& [ key, value ] : settings["commands"].items()) {
        if (!key.contains(command_name))
            continue;

        std::string description = value[0];
        std::size_t size = value.size();

        if (size == 1) {
            suggestions.emplace_back(key, description);
            continue;
        }

        std::string note = "";

        for (std::size_t i = 1; i < size; i++) {
            if (i > 1)
                note.push_back(' ');

            note.append(value[i].get<std::string>());
        }

        suggestions.emplace_back(key, description, note);
    }

    return suggestions;
}

auto plugin::gui::windows::autocompletion::get_all_suggestions_for_argument(const std::string& argument_name) 
    -> std::vector<suggestion_t>
{
    std::vector<suggestion_t> suggestions;

    if (argument_name == "<any>")
        return suggestions;

    if (nlohmann::json& argument = settings["arguments"][argument_name]; !argument.is_null()) {
        for (const auto& suggestion : argument) {
            std::string name = suggestion[0];
            std::string description = suggestion[1];
            suggestions.emplace_back(name, description);
        }

        return suggestions;
    }

    if (predefined_arguments.contains(argument_name))
        predefined_arguments[argument_name](suggestions);
    else
        log::fatal("autocompletion::get_all_suggestions_for_argument: \"{}\" is not a predefined argument",
                   argument_name);

    return suggestions;
}

auto plugin::gui::windows::autocompletion::apply_suggestion(const suggestion_t& suggestion) const -> void {
    std::string result = current_input_text;

    if (suggestion.name[0] == '/' || current_input_text.back() != ' ') {
        std::size_t end_pos = current_input_text.find_last_not_of(" ");

        if (end_pos == std::string::npos) {
            samp::input::set_text(suggestion.name);
            return;
        }

        std::size_t start_pos = current_input_text.find_last_of(" ", end_pos);

        if (start_pos == std::string::npos)
            start_pos = 0;
        else
            start_pos++;

        result.replace(start_pos, end_pos - start_pos + 1, suggestion.name);
    } else {
        result.append(suggestion.name);
    }

    result.push_back(' ');
    samp::input::set_text(result);
}

auto plugin::gui::windows::autocompletion::render_suggestion(const suggestion_t& suggestion, float width, bool selected) const
    -> void
{
    ImVec2 start = ImGui::GetCursorScreenPos();
    ImVec2 end = { start.x + width, start.y + ImGui::GetFontSize() };
    float alpha = (selected) ? 0.5f : 1.0f;

    if (ImGui::IsMouseHoveringRect(start, end)) {
        if (ImGui::IsMouseReleased(ImGuiMouseButton_Left))
            apply_suggestion(suggestion);

        alpha = 0.5f;
    }

    ImGui::PushStyleVar(ImGuiStyleVar_Alpha, alpha);
    {
        ImGui::PushFont(bold_font);
        {
            ImGui::TextUnformatted(suggestion.name.c_str());
        }
        ImGui::PopFont();

        if (suggestion.note.has_value()) {
            ImGui::SameLine();
            ImGui::TextDisabled("%s", suggestion.note->c_str());
        }

        ImVec2 description_text_size = ImGui::CalcTextSize(suggestion.description.c_str());
        float window_padding_x = ImGui::GetStyle().WindowPadding.x;
        float item_spacing_x = ImGui::GetStyle().ItemSpacing.x;

        ImGui::SetCursorScreenPos({ end.x - description_text_size.x - window_padding_x - item_spacing_x, start.y });
        ImGui::TextUnformatted(suggestion.description.c_str());
    }
    ImGui::PopStyleVar();
}

auto plugin::gui::windows::autocompletion::render_hint() const -> void {
    static const std::map<types::zstring_t, types::zstring_t> lines = {
        { "Tab", " - выбор" },
        { "Ctrl + Arrow Up", " - вверх" },
        { "Ctrl + Arrow Down", " - вниз" }
    }; // static const std::map<types::zstring_t, types::zstring_t> lines

    ImGui::PushFont(bold_font);
    {
        for (const auto& [ left, right ] : lines) {
            ImGui::TextUnformatted(left);
            ImGui::SameLine(0.0f, 0.0f);
            ImGui::PushFont(regular_font);
            {
                ImGui::TextUnformatted(right);
            }
            ImGui::PopFont();
        }
    }
    ImGui::PopFont();
}

auto plugin::gui::windows::autocompletion::on_samp_initialize() -> void {
    samp_available = true;
}

auto plugin::gui::windows::autocompletion::on_event(unsigned int message, WPARAM wparam, LPARAM) -> bool {
    auto& window_configuration = (*configuration)["windows"]["autocompletion"];

    if (!window_configuration["use"]
        || message != WM_KEYUP
        || current_suggestions.empty()
        || !samp::input::is_active())
    {
       return true;
    }

    if (wparam == VK_TAB) {
        apply_suggestion(current_suggestions[selected_suggestion_index]);
        return false;
    }

    if (!ImGui::IsKeyDown(ImGuiMod_Ctrl))
        return true;

    std::size_t max_items = window_configuration["max_items"];
    std::size_t suggestions_limit = std::min(current_suggestions.size(), max_items);

    switch (wparam) {
        case VK_UP:
            if (selected_suggestion_index == 0)
                selected_suggestion_index = suggestions_limit - 1;
            else
                selected_suggestion_index--;

            return false;
        case VK_DOWN:
            if (selected_suggestion_index == suggestions_limit - 1)
                selected_suggestion_index = 0;
            else
                selected_suggestion_index++;

            return false;
        default:
            return true;
    }
}

auto plugin::gui::windows::autocompletion::render() -> void {
    auto& window_configuration = (*configuration)["windows"]["autocompletion"];

    if (!window_configuration["use"] || !samp_available || !samp::input::is_active())
        return;

    current_input_text = samp::input::get_text();

    if (current_input_text != old_input_text) {
        current_suggestions = get_suggestions();
        old_input_text = current_input_text;
        selected_suggestion_index = 0;
    }

    if (current_suggestions.empty())
        return;

    auto flags = ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_AlwaysAutoResize; 
    auto [ pos_x, pos_y ] = samp::input::get_position();
    auto [ _, size_y ] = samp::input::get_size();

    ImGui::SetNextWindowPos({ static_cast<float>(pos_x), pos_y + size_y + ImGui::GetStyle().WindowPadding.y });
    ImGui::Begin(get_id(), nullptr, flags);
    {
        float item_width = ImGui::GetFrameHeight() * 17;

        std::size_t max_items = window_configuration["max_items"];
        std::size_t suggestions_size = current_suggestions.size();
        std::size_t suggestions_limit = std::min(suggestions_size, max_items);

        ImGui::BeginGroup();
        {
            for (std::size_t index = 0; index < suggestions_limit; index++)
                render_suggestion(current_suggestions[index], item_width, selected_suggestion_index == index);
        }
        ImGui::EndGroup();

        if (window_configuration["show_hint"] && suggestions_size > 2) {
            ImGui::SameLine();
            ImGui::BeginGroup();
            {
                render_hint();
            }
            ImGui::EndGroup();
        }
    }
    ImGui::End();
}

auto plugin::gui::windows::autocompletion::create(types::not_null<gui_initializer*> child) noexcept
    -> window_ptr_t
{
    return std::make_unique<autocompletion>(child);
}

plugin::gui::windows::autocompletion::autocompletion(types::not_null<gui_initializer*> child)
    : window(child, get_id()),
      bold_font(child->fonts->bold),
      regular_font(child->fonts->regular)
{
#ifdef USE_EMBEDDED_MESSAGE_PACK
      settings = nlohmann::json::from_msgpack(settings_bytes);
#else
      settings = nlohmann::json::parse(settings_bytes);
#endif // USE_EMBEDDED_MESSAGE_PACK

    predefined_arguments["<id>"] = predefined_argument_id;
    predefined_arguments["<car-id>"] = predefined_argument_car_id;
    predefined_arguments["<mycar-id>"] = predefined_argument_mycar_id;
}
