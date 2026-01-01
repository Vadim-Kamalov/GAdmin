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

#include "plugin/gui/windows/main/widgets/frame_switcher.h"
#include "plugin/gui/windows/main/frames/frames.h"
#include "plugin/plugin.h"
#include <unordered_map>

auto plugin::gui::windows::main::widgets::frame_switcher::handle_frame_switching() -> void {
    auto now = std::chrono::steady_clock::now();

    if (now - time_clicked >= fade_in_out_duration)
        return;
    
    bool change_animation_duration = (now - time_clicked >= fade_in_duration);
    std::chrono::milliseconds animation_duration = fade_in_duration;

    if (change_animation_duration) {
        child->child->active_frame = switch_frame;
        (*configuration)["internal"]["main_window_frame"] = std::to_underlying(switch_frame);
        animation_duration = fade_out_duration;
    }

    child->child->active_frame_alpha = animation::bring_to(child->child->active_frame_alpha,
            change_animation_duration * 255, time_clicked, animation_duration);
}

auto plugin::gui::windows::main::widgets::frame_switcher::update_button_size() -> void {
    button_size = { child->width, (button_height_percent * child->child->window_size.y) / 100.0f };
}

auto plugin::gui::windows::main::widgets::frame_switcher::update_current_color() -> void {
    types::color clicked_color = ImGui::GetColorU32(ImGuiCol_FrameBgActive);

    if (child->child->active_frame == switch_frame) {
        current_color = animation::bring_to(current_color, clicked_color, time_clicked, click_animation_duration);
        return;
    }

    types::color hovered_color = ImGui::GetColorU32(ImGuiCol_FrameBgHovered);
    types::color background_color = ImGui::GetColorU32(ImGuiCol_ChildBg);
    
    auto now = std::chrono::steady_clock::now();
    bool hovered = ImGui::IsItemHovered() || now - (time_clicked + click_animation_duration) < 0ms;

    if (hovered != hover_info.state) {
        hover_info.state = hovered;
        hover_info.time = now;
    }

    current_color = animation::bring_to(current_color, (hover_info.state) ? hovered_color : background_color,
                                        hover_info.time, hover_animation_duration);
}

auto plugin::gui::windows::main::widgets::frame_switcher::render_button() -> void {
    ImDrawList* draw_list = ImGui::GetWindowDrawList();
    ImVec2 start = ImGui::GetItemRectMin(), end = ImGui::GetItemRectMax();
    ImVec2 size = ImGui::GetItemRectSize(), spacing = ImGui::GetStyle().ItemSpacing;
    ImU32 text_color = ImGui::GetColorU32(ImGuiCol_Text);
    std::uint8_t frame_index = std::to_underlying(switch_frame);

    draw_list->AddRectFilled(start, end, *current_color);

    types::zstring_t text = frames::label_list[frame_index];
    ImVec2 text_size = bold_font->CalcTextSizeA(text_font_size, FLT_MAX, 0.0f, text);

    draw_list->AddText(bold_font, text_font_size, { start.x + child->state_width.first + spacing.x,
                                                    start.y + (size.y - text_size.y) / 2.0f }, text_color, text);

    types::zstring_t icon = frames::icon_list[frame_index];
    ImVec2 icon_size = icon_font->CalcTextSizeA(icon_font_size, FLT_MAX, 0.0f, icon);

    draw_list->AddText(icon_font, icon_font_size, { start.x + (child->state_width.first - icon_size.x) / 2.0f,
                                                    start.y + (size.y - icon_size.y) / 2.0f }, text_color, icon);
}

auto plugin::gui::windows::main::widgets::frame_switcher::render() -> void {
    std::string button_id = std::format("widgets::frame_switcher[{}]", std::to_underlying(switch_frame));

    update_button_size();
    handle_frame_switching();

    if (ImGui::InvisibleButton(button_id.c_str(), button_size)
        && child->child->active_frame != switch_frame
        && child->child->active_frame_alpha == 255)
    {
        time_clicked = std::chrono::steady_clock::now();
    }

    update_current_color();
    render_button();
}
    
auto plugin::gui::windows::main::widgets::frame_switcher::get_from_pool(types::not_null<frame_selector*> child, const frame& switch_frame)
    noexcept -> std::unique_ptr<frame_switcher>&
{
    static std::unordered_map<frame, std::unique_ptr<frame_switcher>> pool;

    if (!pool.contains(switch_frame))
        pool[switch_frame] = std::make_unique<frame_switcher>(child, switch_frame);

    return pool[switch_frame];
}
