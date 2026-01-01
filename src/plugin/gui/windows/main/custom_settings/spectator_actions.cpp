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

#include "plugin/gui/windows/main/custom_settings/spectator_actions.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/gui/widgets/toggle_button.h"
#include "plugin/server/spectator.h"
#include <imgui.h>
#include <misc/cpp/imgui_stdlib.h>

auto plugin::gui::windows::main::custom_settings::spectator_actions::render_lines(float width, nlohmann::json& setter) -> void {
    float frame_height = ImGui::GetFrameHeight();
    std::size_t size = setter.size();

    ImGuiListClipper clipper;
    clipper.Begin(size);
        
    while (clipper.Step()) {
        for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
            std::string str_index = std::to_string(i);
            std::string item_name = setter[i]["name"];
                
            ImVec2 start_pos = ImGui::GetCursorScreenPos();
            ImVec2 button_size = { button_width, frame_height - button_border_size * button_count_on_line };

            auto up_button = widgets::button("Вверх##spectator_actions:" + str_index, button_size)
                .with_draw_flags(ImDrawFlags_RoundCornersNone);
                
            auto down_button = widgets::button("Вниз##spectator_actions:" + str_index, button_size)
                .with_draw_flags(ImDrawFlags_RoundCornersNone);

            auto configure_button = widgets::button("Настроить##spectator_actions:" + str_index, button_size)
                .with_draw_flags(ImDrawFlags_RoundCornersRight);
               
            ImGui::PushStyleColor(ImGuiCol_ChildBg, ImGui::GetStyle().Colors[ImGuiCol_Button]);
            ImGui::BeginChild(str_index.c_str(), { width, frame_height });
            {
                ImGui::SetCursorPos({ ImGui::GetStyle().FramePadding.x,
                                      (frame_height - ImGui::CalcTextSize(item_name.c_str()).y) / 2.0f });
                    
                ImGui::TextUnformatted(item_name.c_str());
                    
                ImGui::SetCursorPos({ width - button_width * button_count_on_line
                        - button_border_size * (button_count_on_line + 1), button_border_size });
                    
                ImGui::BeginGroup();
                {
                    if (up_button.render() && i > 0)
                        std::swap(setter[i], setter[i - 1]);

                    ImGui::SameLine(0, button_border_size);

                    if (down_button.render() && i + 1 < size)
                        std::swap(setter[i], setter[i + 1]);
                    
                    ImGui::SameLine(0, button_border_size);

                    if (configure_button.render())
                        selected_index = i;
                }
                ImGui::EndGroup();
            }
            ImGui::EndChild();
            ImGui::PopStyleColor();
        }
    }
}

auto plugin::gui::windows::main::custom_settings::spectator_actions::render(types::not_null<gui_initializer*> gui, nlohmann::json& setter) -> void {
    ImGui::BeginChild(get_id(), { std::max<float>(450.0f, ImGui::GetContentRegionAvail().x), 400.0f }, ImGuiChildFlags_AlwaysUseWindowPadding);
    {
        float width = ImGui::GetContentRegionAvail().x;
        float font_size = ImGui::GetFontSize();
        ImFont* bold_font = gui->fonts->bold;

        nlohmann::json& selected_entry = setter[selected_index];
        selected_action_from_menu = selected_entry["action"].is_number();

        widgets::text(bold_font, font_size, 0, "Название кнопки");
        ImGui::SetNextItemWidth(width);
        ImGui::InputText("##spectator_actions.buttons.name", &selected_entry["name"].get_ref<std::string&>());
        widgets::text(bold_font, font_size, 0, "Действие кнопки");
        ImGui::SetNextItemWidth(width);
        
        if (ImGui::SliderInt("##spectator_actions.buttons.action_selector",
                             reinterpret_cast<int*>(&selected_action_from_menu), false, true,
                             action_selector_placeholders[selected_action_from_menu]))
        {
            if (selected_action_from_menu) {
                selected_entry["action"] = nlohmann::json::number_unsigned_t(0);
            } else {
                selected_entry["action"] = "";
            }
        }
        
        ImGui::SetNextItemWidth(width);

        if (selected_action_from_menu) {
            auto& value = selected_entry["action"].get_ref<nlohmann::json::number_unsigned_t&>();
            std::string placeholder = server::spectator::menu_option_descriptions[value];
            std::size_t range_limit = std::size(server::spectator::menu_option_descriptions) - 1;

            ImGui::SliderInt("##spectator_actions.buttons.action:slider_int", reinterpret_cast<int*>(&value), 0, range_limit,
                             placeholder.c_str());
        } else {
            ImGui::InputText("##spectator_actions.buttons.action:input_text", &selected_entry["action"].get_ref<std::string&>());
        }

        widgets::toggle_button("Отображать кнопку##spectator_actions.buttons", selected_entry["use"].get_ref<bool&>())
            .render();

        render_lines(width, setter);
    }
    ImGui::EndChild();
}
