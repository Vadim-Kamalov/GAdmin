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

#include "plugin/gui/windows/admins.h"
#include "plugin/game/game.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/misc/features/nickname_colors.h"
#include "plugin/server/admins.h"
#include "plugin/server/user.h"
#include "plugin/plugin.h"

auto plugin::gui::windows::admins::get_window_information() const -> window_information_t {
    auto& window_configuration = (*configuration)["windows"]["admins"];
    window_information_t information;

    if (!window_configuration["use"] || !server::user::is_on_alogin())
        return information;

    server::admin::sort_option sort_option = window_configuration["sort_by"];
    std::vector<server::admin> admins = server::admins::list;
    server::admin::sort(admins, sort_option);
    
    widgets::aligner::mode_t align_mode = window_configuration["align"];
    bool use_nickname_colors = (*configuration)["misc"]["nickname_colors"];
    bool show_title = window_configuration["show_title"];
    bool show_level = window_configuration["show_level"];
    bool show_id = window_configuration["show_id"];

    if (show_title) {
        information.title = "Список администраторов";

        if (window_configuration["show_count"])
            std::format_to(std::back_inserter(information.title), " (всего: {})", admins.size());

        information.window_width = title_font->CalcTextSizeA(title_font_size, FLT_MAX, 0.0f, information.title.c_str()).x
            + border_size * 2;
    }

    for (const auto& admin : admins) {
        entry_t entry = { .color = ImGui::GetColorU32(ImGuiCol_Text), .text = admin.nickname };

        if (show_level)
            entry.text = std::format("[LVL: {}] {}", admin.level, admin.nickname);

        if (show_id)
            std::format_to(std::back_inserter(entry.text), "[{}]", admin.id);

        float width = entry_font->CalcTextSizeA(entry_font_size, FLT_MAX, 0.0f, entry.text.c_str()).x
            + border_size * 2;
        
        if (information.window_width < width)
            information.window_width = width;

        entry.aligner = widgets::aligner(align_mode, width);

        if (use_nickname_colors) {
            auto& nickname_colors = misc::get_nickname_colors();
            if (auto it = std::find_if(nickname_colors.begin(), nickname_colors.end(), [admin](const auto& entry) {
                return entry.nickname == admin.nickname;
            }); it != nickname_colors.end()) {
                entry.color = it->colors[0];
            }
        }

        information.entries.push_back(entry);
    }
    
    std::size_t show_scrollbar_on = window_configuration["show_scrollbar_on"];
    std::size_t entry_count = std::min(information.entries.size(), show_scrollbar_on);
    float item_spacing_y = ImGui::GetStyle().ItemSpacing.y;

    information.scroll_area_height = (entry_font_size + item_spacing_y) * entry_count - item_spacing_y;
    information.window_width += ImGui::GetStyle().WindowPadding.x * 2;
    information.render = true;

    if (show_scrollbar_on < information.entries.size())
        information.window_width += ImGui::GetStyle().ScrollbarSize;

    return information;
}

auto plugin::gui::windows::admins::render() -> void {
    window_information_t window_information = get_window_information();

    if (!window_information.render)
        return;

    auto [ size_x, size_y ] = game::get_screen_resolution();

    ImGui::SetNextWindowPos({ size_x / 1.11953f, size_y / 2.35664f }, ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowSize({ window_information.window_width, 0 });
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize);
    {
        if (!window_information.title.empty())
            widgets::text(title_font, title_font_size, border_size, "{}", window_information.title);

        ImGui::PushStyleColor(ImGuiCol_ScrollbarBg, { 0, 0, 0, 0 });
        ImGui::BeginChild("windows::admins::content", { 0, window_information.scroll_area_height },
                          ImGuiChildFlags_None, ImGuiWindowFlags_NoBackground);
        {
            ImGuiListClipper clipper;

            clipper.Begin(window_information.entries.size());

            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    entry_t& entry = window_information.entries[i];
                    ImGui::PushStyleColor(ImGuiCol_Text, *entry.color);
                    {
                        entry.aligner.align_next_item(0);
                        widgets::text(entry_font, entry_font_size, border_size, "{}", entry.text);
                    }
                    ImGui::PopStyleColor();
                }
            }
        }
        ImGui::EndChild();
        ImGui::PopStyleColor();
    }
    ImGui::End();
}

auto plugin::gui::windows::admins::create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t {
    return std::make_unique<admins>(child);
}
