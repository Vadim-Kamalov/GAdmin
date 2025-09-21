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

#include "plugin/gui/windows/main/widgets/binder_variables_popup.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/gui/gui.h"
#include <misc/cpp/imgui_stdlib.h>

auto plugin::gui::windows::main::widgets::binder_variables_popup::get_filtered_binder_variables() const ->
    std::deque<server::binder::variable_t>
{
    return server::binder::variables | std::views::filter([this](const auto& variable) {
        return search.contains("{} {}", variable.name, variable.description);
    }) | std::ranges::to<std::deque<server::binder::variable_t>>();
}

auto plugin::gui::windows::main::widgets::binder_variables_popup::render_variable(const server::binder::variable_t& variable)
    -> void
{
    ImVec2 padding = ImGui::GetStyle().FramePadding;
    ImVec2 spacing = ImGui::GetStyle().ItemSpacing;

    bool has_parameters = !variable.parameters_info.empty();
    float height_offset = (has_parameters) ? common_font_size + spacing.y : 0;

    if (gui::widgets::button("", "binder-variable:" + variable.name, {
        ImGui::GetContentRegionAvail().x,
        common_font_size + padding.y * 2 + height_offset
    }).render()) {
        if (inserter != nullptr) {
            std::format_to(std::back_inserter(*inserter), "${{{{ {}", variable.name);
            
            if (!parameter.empty())
                std::format_to(std::back_inserter(*inserter), ", {}", parameter);

            inserter->append(" }}");
        }

        parameter.clear();
        popup.close();
    }

    ImVec2 rect_min = ImGui::GetItemRectMin();
    ImVec2 pos = { rect_min.x + padding.x, rect_min.y + padding.y };

    ImU32 color = ImGui::GetColorU32(ImGuiCol_Text);
    ImDrawList* draw_list = ImGui::GetWindowDrawList();

    draw_list->AddText(bold_font, common_font_size, pos, color, variable.name.c_str());
    pos.x += bold_font->CalcTextSizeA(common_font_size, FLT_MAX, 0.0f, variable.name.c_str()).x + spacing.x;
    draw_list->AddText(regular_font, common_font_size, pos, color, variable.description.c_str());

    if (!has_parameters)
        return;
    
    pos = { rect_min.x + padding.x, rect_min.y + padding.y + spacing.y + common_font_size };
    color = ImGui::GetColorU32(ImGuiCol_TextDisabled);

    draw_list->AddText(bold_font, common_font_size, pos, color, "Параметр:");
    pos.x += bold_font->CalcTextSizeA(common_font_size, FLT_MAX, 0.0f, "Параметр:").x + spacing.x;
    draw_list->AddText(regular_font, common_font_size, pos, color, variable.parameters_info.c_str());
}

auto plugin::gui::windows::main::widgets::binder_variables_popup::popup_renderer() -> void {
    float region_avail_x = ImGui::GetContentRegionAvail().x;
    
    gui::widgets::text(bold_font, title_font_size, 0, "Переменные биндера");
    ImGui::PushFont(regular_font, common_font_size);
    {
        search.render(region_avail_x, "Поиск");
        ImGui::SetNextItemWidth(region_avail_x);
        ImGui::InputTextWithHint(("##binder_variables_popup:" + id).c_str(), "Параметр переменной", &parameter);
        ImGui::BeginChild(("binder_variables_popup:" + id).c_str(), scrollable_area_size,
                          ImGuiChildFlags_AlwaysUseWindowPadding);
        {
            for (const auto& variable : get_filtered_binder_variables())        
                render_variable(variable);
        }
        ImGui::EndChild();
    }
    ImGui::PopFont();
}

plugin::gui::windows::main::widgets::binder_variables_popup::binder_variables_popup(
    const std::string_view& id,
    types::not_null<initializer*> child
) : id(std::move(id)),
    child(child),
    search(id + std::string(":search")),
    popup(id + std::string(":popup")),
    bold_font(child->child->fonts->bold),
    regular_font(child->child->fonts->regular)
{
    popup.set_renderer(std::bind(&binder_variables_popup::popup_renderer, this));
}
