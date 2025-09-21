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

#include "plugin/gui/windows/main/widgets/frame_selector_toggle.h"

auto plugin::gui::windows::main::widgets::frame_selector_toggle::handle_hover_animation() -> void {
    types::color hovered_color = ImGui::GetColorU32(ImGuiCol_ButtonHovered);
    types::color background_color = ImGui::GetColorU32(ImGuiCol_ChildBg);
    
    hover_info.update();

    current_color = animation::bring_to(current_color, (hover_info.state) ? hovered_color : background_color,
                                        hover_info.time, animation_duration);
}

auto plugin::gui::windows::main::widgets::frame_selector_toggle::handle_background() -> void {
    if (std::chrono::steady_clock::now() - time_clicked >= animation_duration)
        return;

    child->child->window_items_alpha = animation::bring_to(child->child->window_items_alpha, (child->state) ? 100 : 255,
                                                           time_clicked, animation_duration);
}

auto plugin::gui::windows::main::widgets::frame_selector_toggle::render_rect_with_icon() -> void {
    ImVec2 start = ImGui::GetItemRectMin();
    ImVec2 end = ImGui::GetItemRectMax();

    ImGui::GetWindowDrawList()->AddRectFilled(start, end, *current_color, ImGui::GetStyle().ChildRounding,
                                              ImDrawFlags_RoundCornersTopLeft);

    ImGui::PushFont(icon_font, icon_font_size);
    {
        ImVec2 icon_size = ImGui::CalcTextSize(icon);
        float button_height = child->state_width.first;
        
        ImGui::SetCursorPos({ (button_height - icon_size.x) / 2.0f, (button_height - icon_size.y) / 2.0f });
        ImGui::TextUnformatted(icon);
    }
    ImGui::PopFont();
}

auto plugin::gui::windows::main::widgets::frame_selector_toggle::update_menu_width() -> void {
    child->width = animation::bring_to(child->width, (child->state) ? child->state_width.second : child->state_width.first,
                                       time_clicked, width_change_duration);
}

auto plugin::gui::windows::main::widgets::frame_selector_toggle::switch_menu_state() -> void {
    if (child->state)
        child->child->window_flags &= ~ImGuiWindowFlags_NoInputs;
    else
        child->child->window_flags |= ImGuiWindowFlags_NoInputs;
    
    time_clicked = std::chrono::steady_clock::now();
    child->state ^= true;
}

auto plugin::gui::windows::main::widgets::frame_selector_toggle::render() -> void {
    if (ImGui::InvisibleButton("widgets::frame_selector_toggle", { child->width, child->state_width.first }))
        switch_menu_state();

    handle_background();
    handle_hover_animation();
    render_rect_with_icon();
    update_menu_width();
}
