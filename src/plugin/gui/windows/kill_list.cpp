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

#include "plugin/gui/windows/kill_list.h"
#include "plugin/gui/widgets/aligner.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/samp/core/kill_list.h"
#include "plugin/server/user.h"
#include "plugin/game/game.h"
#include "plugin/common_utils.h"
#include "plugin/plugin.h"
#include <algorithm>

auto plugin::gui::windows::kill_list::player_t::to_string() const -> std::string {
    return std::format("{}[{}]", nickname, id);
}

auto plugin::gui::windows::kill_list::player_t::render(bool clist_color, ImFont* font) const -> void {
    if (clist_color)
        ImGui::PushStyleColor(ImGuiCol_Text, *color);

    widgets::text(font, common_font_size, text_border_size, "{}", to_string());

    if (clist_color)
        ImGui::PopStyleColor();
}
 
auto plugin::gui::windows::kill_list::get_render_safe_color(const types::color& color) noexcept -> types::color {
    return (color == 0xFFFFFFFF || color == 0) ? ImGui::GetColorU32(ImGuiCol_Text) : color;
}

auto plugin::gui::windows::kill_list::get_window_size(bool show_title) const -> ImVec2 {
    float spacing_y = ImGui::GetStyle().ItemSpacing.y;
    ImVec2 window_padding = ImGui::GetStyle().WindowPadding;
    ImVec2 window_size = { window_padding.x * 2.0f, window_padding.y * 2.0f };

    if (show_title)
        window_size.y += title_font_size + spacing_y;

    window_size.x += max_entry_width;
    window_size.y += (common_font_size + spacing_y) * entries.size() - spacing_y;

    return window_size;
}

auto plugin::gui::windows::kill_list::update_max_entry_width() -> void {
    auto max_width = std::ranges::max_element(entries, {}, &entry_t::width);

    if (max_width == entries.end())
        return;

    max_entry_width = max_width->width;
}

auto plugin::gui::windows::kill_list::write_entry_width(entry_t& entry) -> void {
    float spacing_x = ImGui::GetStyle().ItemSpacing.x;
    float width = bold_font->CalcTextSizeA(common_font_size, FLT_MAX, 0.0f, entry.left.to_string().c_str()).x
        + spacing_x + regular_font->CalcTextSizeA(common_font_size, FLT_MAX, 0.0f, entry.reason.c_str()).x
        + text_border_size * 2;

    if (!entry.time.empty())
        width += bold_font->CalcTextSizeA(common_font_size, FLT_MAX, 0.0f, entry.time.c_str()).x + spacing_x;

    if (entry.right.has_value())
        width += bold_font->CalcTextSizeA(common_font_size, FLT_MAX, 0.0f, entry.right->to_string().c_str()).x + spacing_x;

    if (max_entry_width < width)
        max_entry_width = width;

    entry.width = width;
}

auto plugin::gui::windows::kill_list::try_write_entry_right_player(std::uint16_t id, entry_t& entry) const -> void {
    if (id == samp::event<samp::event_id::player_death_notification>::id_none)
        return;

    samp::player samp_player(id);

    if (!samp_player)
        return;

    player_t player(samp_player);
    entry.right = entry.left;
    entry.left = player;
}

auto plugin::gui::windows::kill_list::on_player_death_notification(const samp::event<samp::event_id::player_death_notification>& notification)
    -> bool
{
    auto& window_configuration = (*configuration)["windows"]["kill_list"];
    
    if (!window_configuration["use"] || !server::user::is_on_alogin())
        return true;

    samp::player left_player(notification.killed_id);

    if (!left_player)
        return true;
    
    bool need_to_update_max_width = false;
    bool show_time = window_configuration["show_time"];
    std::size_t max_count = window_configuration["max_count"];

    entry_t entry = {
        .left = player_t(left_player),
        .reason = notification.get_reason(),
        .time = (show_time) ? common_utils::get_current_timestamp() : ""
    };

    try_write_entry_right_player(notification.killer_id, entry);
    write_entry_width(entry);
    entries.push_back(entry);

    while (entries.size() > max_count) {
        if (entries.front().width == max_entry_width)
            need_to_update_max_width = true;

        entries.pop_front();
    }

    if (need_to_update_max_width)
        update_max_entry_width();
    
    return true;
}

auto plugin::gui::windows::kill_list::on_event(const samp::event_info& event) -> bool {
    if (event == samp::event_type::incoming_rpc && event == samp::event_id::player_death_notification)
        return on_player_death_notification(event.create<samp::event_id::player_death_notification>());

    return true;
}

auto plugin::gui::windows::kill_list::render() -> void {
    auto& window_configuration = (*configuration)["windows"]["kill_list"];

    if (!window_configuration["use"] || entries.empty() || !server::user::is_on_alogin())
        return;
    
    widgets::aligner::mode_t align_mode = window_configuration["align"];
    bool show_title = window_configuration["show_title"];
    bool clist_color = window_configuration["clist_color"];
    bool hide_samp_window = window_configuration["hide_samp_window"];
    auto [ size_x, size_y ] = game::get_screen_resolution();

    if (hide_samp_window)
        samp::kill_list::hide_window();

    ImGui::SetNextWindowPos({ size_x / 1.29730f, size_y / 3.84411f }, ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowSize(get_window_size(show_title));
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoDecoration);
    {
        if (show_title) {
            widgets::aligner(align_mode, bold_font->CalcTextSizeA(title_font_size, FLT_MAX, 0.0f, title_text).x)
                .align_next_item();

            widgets::text(bold_font, title_font_size, text_border_size, title_text);
        }

        for (const auto& entry : entries) {
            widgets::aligner(align_mode, entry.width).align_next_item();
            ImGui::BeginGroup();
            {
                if (!entry.time.empty()) {
                    widgets::text(bold_font, common_font_size, text_border_size, "{}", entry.time);
                    ImGui::SameLine();
                }

                entry.left.render(clist_color, bold_font);
                ImGui::SameLine();
                widgets::text(regular_font, common_font_size, text_border_size, "{}", entry.reason);

                if (entry.right.has_value()) {
                    ImGui::SameLine();
                    entry.right->render(clist_color, bold_font);
                }
            }
            ImGui::EndGroup();
        }
    }
    ImGui::End();
}

auto plugin::gui::windows::kill_list::create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t {
    return std::make_unique<kill_list>(child);
}
