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

#include "plugin/gui/windows/spectator_actions.h"
#include "plugin/game/game.h"
#include "plugin/gui/icon.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/samp/core/menu.h"
#include "plugin/server/binder.h"
#include "plugin/server/spectator.h"
#include "plugin/plugin.h"

auto plugin::gui::windows::to_json(nlohmann::json& json, const spectator_actions::button& button) -> void {
    json["use"] = button.use;
    json["name"] = button.name;

    if (std::holds_alternative<int>(button.action))
        json["action"] = std::get<int>(button.action);
    else
        json["action"] = std::get<std::string>(button.action);
}

auto plugin::gui::windows::from_json(const nlohmann::json& json, spectator_actions::button& button) -> void {
    button.use = json["use"];
    button.name = json["name"];

    if (json["action"].is_number())
        button.action = json["action"].get<int>();
    else if (json["action"].is_string())
        button.action = json["action"].get<std::string>();
}

auto plugin::gui::windows::spectator_actions::render() -> void {
    auto& window_configuration = (*configuration)["windows"]["spectator_actions"];

    if (!window_configuration["use"] || !server::spectator::can_render())
        return;

    server::spectator_information information = server::spectator::get_information();
    auto [ size_x, size_y ] = game::get_screen_resolution();

    std::string left_information = std::format("{}", server::spectator::platform);
    std::string center_information = std::format("Скорость: {} / {} · Оружие: {} · Здоровье: {} · Пинг: {}",
                                                 information.move_speed_current, information.move_speed_max,
                                                 information.weapon, information.health, information.ping);

    ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, { 2, 2 });
    ImGui::SetNextWindowSizeConstraints({ 700, 120 }, { FLT_MAX, FLT_MAX });
    ImGui::SetNextWindowPos({ size_x / 83.47826f, size_y / 1.15543f }, ImGuiCond_FirstUseEver);
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoTitleBar);
    {
        ImGui::BeginGroup();
        {
            ImGui::PushFont(child->fonts->bold, 16);
            {
                ImGui::TextUnformatted(std::format("{}[{}]", server::spectator::nickname, server::spectator::id).c_str());
            }
            ImGui::PopFont();
            ImGui::PushFont(child->fonts->regular, 16);
            {
                ImGui::SameLine((ImGui::GetWindowWidth() - ImGui::CalcTextSize(center_information.c_str()).x) / 2);
                ImGui::TextUnformatted(center_information.c_str());
            }
            ImGui::PopFont();
            ImGui::PushFont(child->fonts->bold, 16);
            {
                ImGui::SameLine();
                ImGui::SetCursorPosX(ImGui::GetWindowWidth() - ImGui::CalcTextSize(left_information.c_str()).x - ImGui::GetStyle().WindowPadding.x);
                ImGui::TextUnformatted(left_information.c_str());
            }
            ImGui::PopFont();
        }
        ImGui::EndGroup();
        ImGui::SetCursorPosY(ImGui::GetCursorPosY() - ImGui::GetStyle().ItemSpacing.y + ImGui::GetStyle().WindowPadding.y);
        ImGui::BeginGroup();
        {
            std::vector<button> buttons = window_configuration["buttons"];
            bool show_corner_buttons = window_configuration["show_corner_buttons"];

            int size = std::count_if(buttons.begin(), buttons.end(), [](button it) { return it.use; });
            bool has_tall_button = size % 2 != 0;
            int offset_corner_buttons = static_cast<int>(show_corner_buttons) + static_cast<int>(has_tall_button);
            int buttons_on_line = size / 2;

            ImVec2 spacing = ImGui::GetStyle().ItemSpacing;
            float padding = ImGui::GetStyle().WindowPadding.x * 2;
            float button_height = (ImGui::GetWindowHeight() - ImGui::GetCursorPosY() - ImGui::GetStyle().WindowPadding.y - spacing.y) / 2;
            float tall_button_height = button_height * 2 + spacing.y;
            float button_width = (ImGui::GetWindowWidth() - padding - std::max<int>(0, buttons_on_line + offset_corner_buttons - 1) 
                    * spacing.x) / (buttons_on_line + offset_corner_buttons);

            if (show_corner_buttons) {
                ImGui::PushFont(child->fonts->icon, 24);
                {
                    auto button = widgets::button(ICON_CHEVRON_LEFT "##windows::spectator_actions", { button_width / 2, tall_button_height })
                        .with_draw_flags(ImDrawFlags_RoundCornersLeft);

                    if (button.render())
                        server::spectator::send_menu_option<server::spectator::menu_option::back>();
                }
                ImGui::PopFont();
                ImGui::SameLine();
            }
            
            ImGui::BeginGroup();
            {
                if (size > 0) {
                    float first_line_pos_y = ImGui::GetCursorPosY();
                    int active_button_count = 0;

                    ImGui::PushFont(child->fonts->regular, 15);
                    ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 0);
                    ImGui::BeginGroup();
                    {
                        for (const auto& [ index, button ] : buttons | std::views::enumerate) {
                            if (!button.use)
                                continue;

                            bool tall_button = ++active_button_count == size && has_tall_button;
                            widgets::button button_widget(button.name, "spectator_actions_button:" + std::to_string(index),
                                                         { button_width, (tall_button) ? tall_button_height : button_height });

                            if (tall_button)
                                ImGui::SetCursorPosY(first_line_pos_y);

                            if (button_widget.render()) {
                                if (std::holds_alternative<int>(button.action)) {
                                    samp::menu::select(std::get<int>(button.action));
                                } else {
                                    server::binder::evaluate(std::get<std::string>(button.action));
                                }
                            }
                       
                            if (!tall_button && size >= 2 && active_button_count != buttons_on_line)
                                ImGui::SameLine();
                        }
                    }
                    ImGui::EndGroup();
                    ImGui::PopStyleVar();
                    ImGui::PopFont();
                }
            }
            ImGui::EndGroup();
            
            if (show_corner_buttons) {
                ImGui::SameLine();
                ImGui::PushFont(child->fonts->icon, 24);
                {
                    auto button = widgets::button(ICON_CHEVRON_RIGHT "##windows::spectator_actions", { button_width / 2, tall_button_height })
                        .with_draw_flags(ImDrawFlags_RoundCornersRight);
                    
                    if (button.render())
                        server::spectator::send_menu_option<server::spectator::menu_option::next>();
                }
                ImGui::PopFont();
            }
        }
        ImGui::EndGroup();
    }
    ImGui::End();
    ImGui::PopStyleVar();
}

auto plugin::gui::windows::spectator_actions::create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t {
    return std::make_unique<spectator_actions>(child);
}
