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

#include "plugin/gui/windows/main/frames/plugin_information.h"
#include "plugin/gui/widgets/markdown.h"
#include "plugin/gui/gui.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/types/simple.h"

static constexpr std::uint8_t markdown_text_start[] = {
#embed "../../../../../../embed/plugin_information/start.md"
}; // static constexpr std::uint8_t markdown_text_start[]
    
static constexpr std::uint8_t markdown_text_end[] = {
#embed "../../../../../../embed/plugin_information/end.md"
}; // static constexpr std::uint8_t markdown_text_end[]

auto plugin::gui::windows::main::frames::plugin_information::get_nicknames_information() const -> nicknames_information_t {
    auto& nickname_colors = misc::get_nickname_colors();
    nicknames_information_t information;

    for (std::size_t group_index = 0, group_end = (nickname_colors.size() + nickname_count_per_group - 1) / nickname_count_per_group;
         group_index < group_end; group_index++)
    {
        std::size_t group_start = group_index * nickname_count_per_group;
        std::size_t group_bound = std::min(group_start + nickname_count_per_group, nickname_colors.size());
        std::deque<nicknames_information_t::entry_t> entries;
        float group_width = 0;

        for (std::size_t index = group_start; index < group_bound; index++) {
            auto& entry = nickname_colors[index];

            if (float nickname_width = ImGui::CalcTextSize(entry.nickname.c_str()).x; group_width < nickname_width)
                group_width = nickname_width;

            entries.push_back(entry);
        }

        information.total_width += group_width + nickname_group_spacing_x;

        if (group_index == 0) {
            information.grops.push_back({ 0, entries });
            continue;
        }

        information.grops.push_back({ information.total_width - group_width, entries });
    }

    information.total_width -= nickname_group_spacing_x;

    return information;
}

auto plugin::gui::windows::main::frames::plugin_information::render_centered_text(types::not_null<ImFont*> font, float font_size, types::zstring_t text) const
    -> void
{
    ImGui::PushFont(font, font_size);
    {
        ImGui::SetCursorPosX((ImGui::GetContentRegionAvail().x - ImGui::CalcTextSize(text).x) / 2);
        ImGui::TextUnformatted(text);
    }
    ImGui::PopFont();
}

auto plugin::gui::windows::main::frames::plugin_information::render() -> void {
    types::not_null<ImFont*> bold_font = child->child->fonts->bold;
    types::not_null<ImFont*> light_font = child->child->fonts->light;

    render_centered_text(bold_font, header_font_size, header_text);
    widgets::markdown(reinterpret_cast<types::zstring_t>(markdown_text_start), bold_font).render();
    ImGui::NewLine();

    auto nicknames_information = get_nicknames_information();
    float start = (ImGui::GetContentRegionAvail().x - nicknames_information.total_width) / 2;

    for (const auto& group : nicknames_information.grops) {
        ImGui::SameLine(start + group.offset_from_start_x);
        ImGui::BeginGroup();
        {
            for (const auto& entry : group.entries) {
                ImGui::PushStyleColor(ImGuiCol_Text, *entry.colors[0]);
                widgets::text(bold_font, nickname_font_size, 1, "{}", entry.nickname);
                ImGui::PopStyleColor();
            }
        }
        ImGui::EndGroup();
    }

    ImGui::NewLine();
    widgets::markdown(reinterpret_cast<types::zstring_t>(markdown_text_end), bold_font).render();
    render_centered_text(light_font, footer_font_size, footer_text);
}
