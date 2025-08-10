#include "plugin/gui/windows/main/frames/player_checker.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/samp/core/player_pool.h"
#include "plugin/samp/core/user.h"
#include "plugin/plugin.h"
#include <misc/cpp/imgui_stdlib.h>

auto plugin::gui::windows::main::frames::player_checker::get_added_players_json() -> nlohmann::json& {
    return (*configuration)["windows"]["player_checker"]["players"];
}

auto plugin::gui::windows::main::frames::player_checker::get_filtered_player_list() const -> std::deque<player_online_t> {
    std::deque<player_online_t> players;

    for (std::uint16_t id = 0; id <= SERVER_MAX_PLAYERS; id++) {
        if (id == samp::user::get_id())
            continue;

        if (auto nickname = samp::player_pool::get_nickname(id)) {
            std::string line = std::format("{}[{}]", *nickname, id);

            if (!search.contains(line))
                continue;

            players.push_back({ *nickname, id });
        }
    }

    return players;
}

auto plugin::gui::windows::main::frames::player_checker::render_description_hint(const ImVec2& input_size) const -> void {
    if (!description_text.empty())
        return;

    ImVec2 start = ImGui::GetItemRectMin();
    ImVec2 text_size = ImGui::CalcTextSize(description_hint);
    ImVec2 center = { start.x + (input_size.x - text_size.x) / 2.0f, start.y + (input_size.y - text_size.y) / 2.0f };
    ImU32 color = ImGui::GetColorU32(ImGuiCol_TextDisabled);

    ImGui::GetWindowDrawList()->AddText(regular_font, common_font_size, center, color, description_hint);
}

auto plugin::gui::windows::main::frames::player_checker::render_left_group(float width) -> void {
    float child_height = (ImGui::GetContentRegionAvail().y - ImGui::GetTextLineHeightWithSpacing()) / 1.5f;

    ImGui::BeginChild("players_online", { width, child_height }, ImGuiChildFlags_AlwaysUseWindowPadding, child->window_flags);
    {
        static constexpr types::zstring_t title_text = "Игроки онлайн";
        ImVec2 title_text_size = bold_font->CalcTextSizeA(title_font_size, FLT_MAX, 0.0f, title_text);

        ImGui::SetCursorPosX((ImGui::GetContentRegionAvail().x - title_text_size.x) / 2.0f);
        gui::widgets::text(bold_font, title_font_size, 0, title_text);

        std::deque<player_online_t> players = get_filtered_player_list();
        ImGuiListClipper clipper;
            
        clipper.Begin(players.size());

        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                player_online_t& player = players[i];
                std::string label = std::format("{}[{}]", player.nickname, player.id);

                if (!ImGui::Selectable(label.c_str(), selected_id == player.id))
                    continue;

                selected_id = player.id;
                search.set_text(player.nickname);
            }
        }
    }
    ImGui::EndChild();
    search.render(width, "Никнейм игрока");

    ImVec2 input_size = { width, ImGui::GetContentRegionAvail().y
        - bottom_button_height - ImGui::GetStyle().ItemSpacing.y };

    if (ImGui::InputTextMultiline("##description_input", &description_text, input_size) && search.empty()) {
        nlohmann::json& added_players = get_added_players_json();
        if (selected_player_index < added_players.size())
            added_players[selected_player_index]["description"] = description_text;
    }

    render_description_hint(input_size);
        
    if (gui::widgets::button("Добавить в чекер##frames::player_checker", { width, bottom_button_height })
            .render() && !search.empty())
    {
        nlohmann::json& added_players = get_added_players_json();

        added_players.push_back(added_player_t { search.get_text(), description_text });
        search.clear();

        selected_id = id_none;
        selected_player_index = added_players.size() - 1;
    }
}

auto plugin::gui::windows::main::frames::player_checker::render_right_group(float width) -> void {
    float child_height = ImGui::GetContentRegionAvail().y - ImGui::GetStyle().ItemSpacing.y - bottom_button_height;

    ImGui::BeginChild("players_added", { width, child_height }, ImGuiChildFlags_AlwaysUseWindowPadding, child->window_flags);
    {
        static constexpr types::zstring_t title_text = "Чекер игроков";
        ImVec2 title_text_size = bold_font->CalcTextSizeA(title_font_size, FLT_MAX, 0.0f, title_text);

        ImGui::SetCursorPosX((ImGui::GetContentRegionAvail().x - title_text_size.x) / 2.0f);
        gui::widgets::text(bold_font, title_font_size, 0, title_text);

        std::deque<added_player_t> added_players = get_added_players_json();
        ImGuiListClipper clipper;

        clipper.Begin(added_players.size());

        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                added_player_t& player = added_players[i];
                std::string label = std::format("{}##{}", player.nickname, i);

                if (!ImGui::Selectable(label.c_str(), selected_player_index == i))
                    continue;

                selected_player_index = i;
                description_text = player.description;
                search.clear();
            }
        }
    }
    ImGui::EndChild();

    if (gui::widgets::button("Удалить##frames::player_checker", { width, bottom_button_height }).render()) {
        nlohmann::json& added_players = get_added_players_json();
        if (selected_player_index < added_players.size()) {
            added_players.erase(selected_player_index);
            selected_player_index = 0;
            description_text.clear();
        }
    }
}

auto plugin::gui::windows::main::frames::player_checker::render() -> void {
    float half_width = (ImGui::GetContentRegionAvail().x - ImGui::GetStyle().ItemSpacing.x) / 2.0f;
    
    ImGui::PushFont(regular_font, common_font_size);
    {
        ImGui::BeginGroup();
        {
            render_left_group(half_width);
        }
        ImGui::EndGroup();
        ImGui::SameLine();
        ImGui::BeginGroup();
        {
            render_right_group(half_width);
        }
        ImGui::EndGroup();
    }
    ImGui::PopFont();
}

plugin::gui::windows::main::frames::player_checker::player_checker(types::not_null<initializer*> child)
    : child(child),
      bold_font(child->child->fonts->bold),
      regular_font(child->child->fonts->regular)
{
    nlohmann::json& added_players = get_added_players_json();

    if (added_players.empty())
        return;

    description_text = added_players[selected_player_index]["description"];
}
