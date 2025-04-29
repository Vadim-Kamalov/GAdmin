#include "plugin/gui/windows/players_nearby.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/server/admins.h"
#include "plugin/server/spectator.h"
#include "plugin/server/user.h"
#include "plugin/samp/player.h"
#include "plugin/plugin.h"
#include "plugin/log.h"

plugin::gui::windows::players_nearby::information_t
plugin::gui::windows::players_nearby::get_window_information() const {
    auto window_configuration = (*configuration)["windows"]["players_nearby"];
    sort_option_t sort_option = window_configuration["sort_by"];
    std::size_t show_scrollbar_on = window_configuration["max_count"];

    ImVec2 content_size = { 0, 0 };
    ImVec2 window_padding = ImGui::GetStyle().WindowPadding;
    float spacing_y = ImGui::GetStyle().ItemSpacing.y;

    std::deque<samp::player::stream_entry_t> stream_players = samp::player::get_stream_players();
    std::deque<entry> entries;

    for (const auto& [ player, ped ] : stream_players) {
        entry new_entry;
        {
            game::ped game_ped = ped.get_game_ped();
            types::vector_3d ped_position = game_ped.get_position();

            if (server::spectator::is_active()) {
                if (samp::ped spectator_ped = server::spectator::player.get_ped(); spectator_ped.is_available()) {
                    types::vector_3d spectator_position = spectator_ped.get_game_ped().get_position();
                    new_entry.distance = ped_position.get_distance_to(spectator_position);
                }
            } else {
                types::vector_3d player_position = game::ped::get_player().get_position();
                new_entry.distance = ped_position.get_distance_to(player_position);
            }
        }

        if (window_configuration["show_distance"])
            new_entry.text = std::format("[X: {:.1f}] ", new_entry.distance);

        std::format_to(std::back_inserter(new_entry.text), "{}[{}]", player.nickname, player.id);

        if (auto admin = server::admins::get_admin(player.id); admin.has_value())
            std::format_to(std::back_inserter(new_entry.text), " [{}]", admin->nickname);
    
        ImVec2 text_size = entry_font->CalcTextSizeA(entry_font->FontSize, FLT_MAX, 0, new_entry.text.c_str());

        if (text_size.x > content_size.x)
            content_size.x = text_size.x;

        if (window_configuration["clist_color"]) {
            if (types::color player_color = player.get_color(); player_color != 0xFFFFFFFF) {
                new_entry.color = player_color;
            }
        }

        new_entry.id = player.id;
        new_entry.width = text_size.x;

        entries.push_back(new_entry);
    }
    
    if (window_configuration["show_title"]) {
        std::string title_label = std::format("{} (всего: {})", title, entries.size());
        content_size.x = title_font->CalcTextSizeA(title_font->FontSize, FLT_MAX, 0, title_label.c_str()).x;
    }

    content_size.x += window_padding.x * 2 + ImGui::GetStyle().ScrollbarSize;
    content_size.y = show_scrollbar_on * (entry_font->FontSize + spacing_y + text_border_size) - spacing_y + window_padding.y;

    switch (sort_option) {
        case sort_option_t::length:
            std::ranges::sort(entries, [](const entry& a, const entry& b) { return a.text.length() < b.text.length(); });
            break;
        case sort_option_t::distance:
            std::ranges::sort(entries, {}, &entry::distance);
            break;
        case sort_option_t::id:
            std::ranges::sort(entries, {}, &entry::id);
            break;
        default:
            break;
    }

    return { content_size, entries };
}

void
plugin::gui::windows::players_nearby::render() {
    auto window_configuration = (*configuration)["windows"]["players_nearby"];

    if (!window_configuration["use"] || !server::user::is_on_alogin())
        return;

    auto window_information = get_window_information();

    ImGui::SetNextWindowSize({ window_information.content_size.x, 0 });
    ImGui::SetNextWindowBgAlpha(0);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0);
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize);
    {
        if (window_configuration["show_title"])
            widgets::text(title_font, text_border_size, "{} (всего: {})", title, window_information.entries.size());
        
        ImGui::PushStyleColor(ImGuiCol_ScrollbarBg, 0);
        ImGui::SetCursorPosX(0);
        ImGui::SetNextWindowBgAlpha(0);
        ImGui::BeginChild("windows::players_nearby::entries", window_information.content_size);
        {
            ImGuiListClipper clipper;
            
            clipper.Begin(window_information.entries.size());

            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    auto& entry = window_information.entries[i];
                    float pos_x = ImGui::GetStyle().WindowPadding.x;

                    if (std::string align = window_configuration["align"]; align != "left")
                        pos_x = (align == "right") ? ImGui::GetContentRegionAvail().x - entry.width 
                            : (ImGui::GetContentRegionAvail().x - entry.width) / 2;
                
                    ImGui::SetCursorPosX(pos_x);
                    ImGui::PushStyleColor(ImGuiCol_Text, *entry.color);
                    {
                        widgets::text(entry_font, text_border_size, "{}", entry.text);
                    }
                    ImGui::PopStyleColor();
                }
            }
        }
        ImGui::EndChild();
        ImGui::PopStyleColor();
    }
    ImGui::End();
    ImGui::PopStyleVar();
}

plugin::gui::window_ptr_t
plugin::gui::windows::players_nearby::create(types::not_null<gui_initializer*> child) noexcept {
    return std::make_unique<players_nearby>(child);
}

plugin::gui::windows::players_nearby::players_nearby(types::not_null<gui_initializer*> child) 
    : child(child),
      entry_font((*child->fonts->regular)[16]),
      title_font((*child->fonts->bold)[18])
{
    log::info("window \"windows::players_nearby\" initialized");
}
