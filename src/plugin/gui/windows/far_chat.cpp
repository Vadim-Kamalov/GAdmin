/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
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

#include "plugin/gui/windows/far_chat.h"
#include "plugin/common_utils.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/server/user.h"
#include "plugin/plugin.h"
#include <ctime>

auto plugin::gui::windows::far_chat::get_render_safe_color(const types::color& color) const -> types::color {
    return (color == 0xFFFFFFFF || color == 0) ? ImGui::GetColorU32(ImGuiCol_Text) : color;
}

auto plugin::gui::windows::far_chat::is_duplicate_entry(const std::string_view& message, std::uint16_t player_id, std::chrono::milliseconds delay) const
    -> bool
{
    if (entries.empty())
        return false;

    auto now = std::chrono::steady_clock::now();
    auto& last = entries.back();

    return now - last.steady_time <= delay && last.message == message && last.player.id == player_id;
}

auto plugin::gui::windows::far_chat::on_player_chat_bubble(const samp::event<samp::event_id::player_chat_bubble>& event) -> bool {
    auto& window_configuration = (*configuration)["windows"]["far_chat"];

    if (!window_configuration["use"] || (event.color == 0xFF8054E7 && event.message[0] != '*'))
        return true;
    
    samp::player player(event.player_id);
    long duplicates_delay_ms = window_configuration["duplicates_delay_ms"];

    if (!player || is_duplicate_entry(event.message, event.player_id, std::chrono::milliseconds(duplicates_delay_ms)))
        return true;

    bool show_time = window_configuration["show_time"];
    std::size_t max_count = window_configuration["max_count"];

    entry_t entry = {
        .player = player,
        .player_color = get_render_safe_color(player.get_color()),
        .message_color = get_render_safe_color(event.color),
        .message = event.message,
        .time = common_utils::get_current_timestamp(),
        .steady_time = std::chrono::steady_clock::now()
    };

    entries.push_back(entry);
    
    while (entries.size() > max_count)
        entries.pop_front();

    return true;
}

auto plugin::gui::windows::far_chat::on_event(const samp::event_info& event) -> bool {
    if (event == samp::event_type::incoming_rpc && event == samp::event_id::player_chat_bubble)
        return on_player_chat_bubble(event.create<samp::event_id::player_chat_bubble>());

    return true;
}

auto plugin::gui::windows::far_chat::render() -> void {
    auto& window_configuration = (*configuration)["windows"]["far_chat"];

    if (entries.empty() || !window_configuration["use"] || !server::user::is_on_alogin())
        return;

    float window_width = window_configuration["width"];
    bool show_title = window_configuration["show_title"];
    bool show_time = window_configuration["show_time"];
    bool clist_color = window_configuration["clist_color"];
    auto flags = ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoBackground;

    ImGui::SetNextWindowSize({ window_width, 0 });
    ImGui::Begin(get_id(), nullptr, flags);
    {
        if (show_title)
            widgets::text(bold_font, title_font_size, text_border_size, title_text);

        for (const auto& entry : entries) {
            ImGui::PushTextWrapPos(window_width);
            ImGui::BeginGroup();
            {
                if (show_time) {
                    widgets::text(bold_font, common_font_size, text_border_size, "{}", entry.time);
                    ImGui::SameLine();
                }
                
                if (clist_color)
                    ImGui::PushStyleColor(ImGuiCol_Text, *entry.player_color);

                widgets::text(bold_font, common_font_size, text_border_size, "{}[{}]:", entry.player.nickname, entry.player.id);
                ImGui::SameLine();

                if (clist_color)
                    ImGui::PopStyleColor();

                ImGui::PushStyleColor(ImGuiCol_Text, *entry.message_color);
                {
                    widgets::text(regular_font, common_font_size, text_border_size, "{}", entry.message);
                }
                ImGui::PopStyleColor();
            }
            ImGui::EndGroup();
            ImGui::PopTextWrapPos();
        }
    }
    ImGui::End();
}

auto plugin::gui::windows::far_chat::create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t {
    return std::make_unique<far_chat>(child);
}
