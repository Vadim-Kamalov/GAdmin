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

#include "plugin/gui/windows/main/custom_settings/spectator_information.h"
#include "plugin/gui/widgets/button.h"
#include <imgui.h>

auto plugin::gui::windows::main::custom_settings::spectator_information::render(types::not_null<gui_initializer*>, nlohmann::json& setter) -> void {
    std::size_t size = setter.size();
    ImGuiListClipper clipper;

    ImGui::BeginChild(get_id(), { std::max<float>(450.0f, ImGui::GetContentRegionAvail().x), 400.0f }, ImGuiChildFlags_AlwaysUseWindowPadding);
    {
        float frame_height = ImGui::GetFrameHeight();
        float width = ImGui::GetContentRegionAvail().x;

        clipper.Begin(size);
        
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                std::string str_index = std::to_string(i);
                std::string& item = setter[i].get_ref<std::string&>();
                
                ImVec2 start_pos = ImGui::GetCursorScreenPos();
                ImVec2 button_size = { button_width, frame_height - button_border_size * 2 };

                auto up_button = widgets::button("Вверх##spectator_information:" + str_index, button_size)
                    .with_draw_flags(ImDrawFlags_RoundCornersNone);
                
                auto down_button = widgets::button("Вниз##spectator_information:" + str_index, button_size)
                    .with_draw_flags(ImDrawFlags_RoundCornersRight);
               
                ImGui::PushStyleColor(ImGuiCol_ChildBg, ImGui::GetStyle().Colors[ImGuiCol_Button]);
                ImGui::BeginChild(str_index.c_str(), { width, frame_height });
                {
                    ImGui::SetCursorPos({ ImGui::GetStyle().FramePadding.x,
                                          (frame_height - ImGui::CalcTextSize(item.c_str()).y) / 2.0f });
                    
                    ImGui::TextUnformatted(item.c_str());
                    ImGui::SetCursorPos({ width - button_width * 2 - button_border_size * 3, button_border_size });
                    ImGui::BeginGroup();
                    {
                        if (up_button.render() && i > 0)
                            std::swap(item, setter[i - 1].get_ref<std::string&>());

                        ImGui::SameLine(0, button_border_size);

                        if (down_button.render() && i + 1 < size)
                            std::swap(item, setter[i + 1].get_ref<std::string&>());
                    }
                    ImGui::EndGroup();
                }
                ImGui::EndChild();
                ImGui::PopStyleColor();
            }
        }
    }
    ImGui::EndChild();
}
