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

#include "plugin/gui/windows/main/custom_settings/message_recolorer.h"
#include "plugin/gui/widgets/toggle_button.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/plugin.h"
#include <algorithm>
#include <ranges>

auto plugin::gui::windows::main::custom_settings::message_recolorer::horizontal_align_group() const -> void {
    float spacing_y = ImGui::GetStyle().ItemSpacing.y;
    float window_padding_y = ImGui::GetStyle().WindowPadding.y;
    float font_size = ImGui::GetFontSize();
    float toggle_button_height = std::max<float>(widgets::toggle_button::size.y, font_size);

    ImGui::SetCursorPosY(window_padding_y + ((color_edit_height_width - window_padding_y
                    - count_of_lines_in_group * spacing_y - font_size
                    * count_of_lines_in_group - toggle_button_height) / 2.0f));
}

auto plugin::gui::windows::main::custom_settings::message_recolorer::render_select_buttons(nlohmann::json& setter) -> void {
    for (const auto& [ index, item ] : setter | std::views::enumerate) {
        std::string key = item["key"];

        if (!widgets::button(std::format("{}##{}", key, index),
                            { ImGui::GetContentRegionAvail().x, ImGui::GetFrameHeight() }).render())
        {
            continue;
        }

        types::color color = item["value"];
        color_input_buffer = std::format("{:06X}", color.cast<types::color_type::rgba>() >> 8);
        color_picker_buffer = ImGui::ColorConvertU32ToFloat4(*color);
        selected_item_index = index;
    }
}

auto plugin::gui::windows::main::custom_settings::message_recolorer::render_color_edit(nlohmann::json& setter) -> void {
    auto color_edit_flags = ImGuiColorEditFlags_NoSmallPreview
        | ImGuiColorEditFlags_NoTooltip
        | ImGuiColorEditFlags_NoSmallPreview
        | ImGuiColorEditFlags_NoInputs
        | ImGuiColorEditFlags_NoSidePreview;

    ImGui::SetNextItemWidth(color_edit_height_width);

    if (!ImGui::ColorPicker4("##message_recolorer:color_picker", &color_picker_buffer.x, color_edit_flags))
        return;

    types::color color = ImGui::ColorConvertFloat4ToU32(color_picker_buffer);
    color_input_buffer = std::format("{:06X}", color.cast<types::color_type::rgba>() >> 8);
    setter[selected_item_index]["value"] = color;
}

auto plugin::gui::windows::main::custom_settings::message_recolorer::render_color_input(types::not_null<gui_initializer*> gui,
                                                                                        nlohmann::json& setter, float start,
                                                                                        float width)
    -> void
{
    ImGui::SetCursorPosX(start + (width - ImGui::CalcTextSize("Цвет (кликабельно): #XXXXXX").x) / 2.0f);
    ImGui::BeginGroup();
    {
        ImGui::TextUnformatted("Цвет (кликабельно): ");
        ImGui::SameLine(0.0f, 0.0f);
        ImGui::PushFont(gui->fonts->bold);
        ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, { 0.0f, 0.0f });
        ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 0);
        ImGui::PushStyleColor(ImGuiCol_Text, color_picker_buffer);
        ImGui::PushStyleColor(ImGuiCol_FrameBg, 0);
        ImGui::PushStyleColor(ImGuiCol_FrameBgActive, 0);
        ImGui::PushStyleColor(ImGuiCol_FrameBgHovered, 0);
        {
            ImGui::TextUnformatted("#");
            ImGui::SameLine(0.0f, 0.0f);
            ImGui::SetNextItemWidth(ImGui::CalcTextSize("XXXXXX").x);

            if (ImGui::InputText("##message_recolorer:input_text", color_input_buffer.data(),
                                 color_input_buffer_size, ImGuiInputTextFlags_CharsHexadecimal))
            {
                std::string text_color = color_input_buffer;
                text_color.resize(6, '0');
                text_color.append("FF");

                try {
                    types::color color = types::color::rgba(std::stoull(text_color, nullptr, 16));
                    color_picker_buffer = ImGui::ColorConvertU32ToFloat4(*color);
                    setter[selected_item_index]["value"] = color;
                } catch (const std::exception& e) {
                    log::warn("std::stoull in message_recolorer::render failed: {}", e.what());
                }
            }
        }
        ImGui::PopStyleColor(4);
        ImGui::PopStyleVar(2);
        ImGui::PopFont();
    }
    ImGui::EndGroup();
}

auto plugin::gui::windows::main::custom_settings::message_recolorer::render(types::not_null<gui_initializer*> gui,
                                                                            nlohmann::json& setter) -> void
{
    ImGui::BeginChild(get_id(), { std::max<float>(450.0f, ImGui::GetContentRegionAvail().x), 350.0f },
                      ImGuiChildFlags_AlwaysUseWindowPadding);
    {
        render_color_edit(setter);
        ImGui::SameLine();
        horizontal_align_group();
        ImGui::BeginGroup();
        {
            std::string key = setter[selected_item_index]["key"];
            bool& use = setter[selected_item_index]["use"].get_ref<bool&>();
    
            float start = color_edit_height_width + ImGui::GetStyle().ItemSpacing.x;
            float width = ImGui::GetContentRegionAvail().x;
            float spacing_x = ImGui::GetStyle().ItemSpacing.x;

            ImGui::PushFont(gui->fonts->bold);
            {
                ImGui::SetCursorPosX(start + (width - ImGui::CalcTextSize(key.c_str()).x) / 2.0f);
                ImGui::Text("%s", key.c_str());
            }
            ImGui::PopFont();

            render_color_input(gui, setter, start, width);
            ImGui::SetCursorPosX(start + (width - (ImGui::CalcTextSize("Изменять цвет сообщений").x
                            + widgets::toggle_button::size.x + spacing_x)) / 2.0f);

            widgets::toggle_button("Изменять цвет сообщений##message_recolorer", use).render();
        }
        ImGui::EndGroup();
        render_select_buttons(setter);
    }
    ImGui::EndChild();
}

plugin::gui::windows::main::custom_settings::message_recolorer::message_recolorer() {
    color_input_buffer.reserve(color_input_buffer_size);

    auto& first_item = (*configuration)["misc"]["message_recolorer"]["items"].front();
    types::color color = first_item["value"];

    color_input_buffer = std::format("{:06X}", color.cast<types::color_type::rgba>() >> 8);
    color_picker_buffer = ImGui::ColorConvertU32ToFloat4(*color);
}
