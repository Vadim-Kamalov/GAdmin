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

#include "plugin/gui/windows/main/widgets/plot.h"
#include "plugin/log.h"
#include <algorithm>
#include <ranges>

auto plugin::gui::windows::main::widgets::plot::get_line_size(const line_t& line, const ImVec2& plot_size, value_t max_value) const
    -> ImVec2
{
    std::size_t lines_count = lines.size();
    ImVec2 padding = ImGui::GetStyle().WindowPadding;
    float line_height = 0;

    if (line.value != 0) {
        line_height = plot_size.y - padding.y * 2.0f;

        if (line.value != max_value)
            line_height *= static_cast<float>(line.value) / static_cast<float>(max_value);
    }

    float total_spacing_x = ImGui::GetStyle().ItemSpacing.x * (lines_count - 1);
    float available_width = plot_size.x - padding.x * 2.0f - total_spacing_x;

    return { available_width / lines_count, line_height };
}

auto plugin::gui::windows::main::widgets::plot::set_lines_descriptions(const std::vector<std::string>& descriptions)
    -> void
{
    if (lines.size() != descriptions.size()) {
        log::fatal("widgets::plot: lines.size() != descriptions.size()");
        return;
    }

    for (const auto& [ index, line ] : lines | std::views::enumerate)
        line.description = descriptions[index];
}

auto plugin::gui::windows::main::widgets::plot::set_values(const std::vector<value_t>& values) -> void {
    if (lines.size() != values.size()) {
        log::fatal("widgets::plot: lines.size() != values.size()");
        return;
    }

    for (const auto& [ index, line ] : lines | std::views::enumerate)
        line.value = values[index];
}

auto plugin::gui::windows::main::widgets::plot::render(const ImVec2& size) -> void {
    ImDrawList* draw_list = ImGui::GetWindowDrawList();
    float rounding = ImGui::GetStyle().FrameRounding;

    ImU32 default_color = ImGui::GetColorU32(ImGuiCol_FrameBg);
    ImU32 active_color = ImGui::GetColorU32(ImGuiCol_FrameBgActive);
    ImU32 text_color = ImGui::GetColorU32(ImGuiCol_Text);

    ImVec2 current_pos = ImGui::GetCursorScreenPos();
    ImVec2 padding = ImGui::GetStyle().WindowPadding;
    ImVec2 item_spacing = ImGui::GetStyle().ItemSpacing;

    draw_list->AddRectFilled(current_pos, { current_pos.x + size.x, current_pos.y + size.y },
                             default_color, rounding, ImDrawFlags_RoundCornersAll);

    ImGui::Dummy(size);

    value_t max_plot_value = std::ranges::max(lines, {}, &line_t::value).value;

    if (max_plot_value == 0) {
        ImGui::PushFont(nullptr, empty_text_font_size);
        {
            ImVec2 text_size = ImGui::CalcTextSize(empty_text);
            ImVec2 center = { current_pos.x + (size.x - text_size.x) / 2.0f, current_pos.y + (size.y - text_size.y) / 2.0f };
            draw_list->AddText(center, ImGui::GetColorU32(ImGuiCol_TextDisabled), empty_text);
        }
        ImGui::PopFont();

        return;
    }

    float max_line_height = size.y - padding.y - ImGui::GetFontSize();

    current_pos.x += padding.x;
    current_pos.y += max_line_height;

    for (const auto& line : lines) {
        ImVec2 line_size = get_line_size(line, { size.x, max_line_height }, max_plot_value);
        std::string value = value_formatter(line.value);

        float description_center_x = (line_size.x - ImGui::CalcTextSize(line.description.c_str()).x) / 2.0f;
        float value_center_x = (line_size.x - ImGui::CalcTextSize(value.c_str()).x) / 2.0f;

        if (line_size.y > 0)
            draw_list->AddRectFilled({ current_pos.x, current_pos.y - padding.y },
                                     { current_pos.x + line_size.x, current_pos.y - line_size.y - padding.y },
                                     active_color);
        
        draw_list->AddText({ current_pos.x + description_center_x, current_pos.y }, text_color, line.description.c_str());
        draw_list->AddText({ current_pos.x + value_center_x, current_pos.y - std::max(padding.y * 2.5f, line_size.y) - padding.y },
                           text_color, value.c_str());

        current_pos.x += line_size.x + item_spacing.x;
    }
}
