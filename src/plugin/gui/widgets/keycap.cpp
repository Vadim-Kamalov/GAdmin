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

#include "plugin/gui/widgets/keycap.h"
#include "plugin/gui/animation.h"

auto plugin::gui::widgets::keycap::render() const -> void {
    using namespace std::chrono_literals;

    types::color active_color = ImGui::GetColorU32(ImGuiCol_FrameBgActive);
    types::color default_color = ImGui::GetColorU32(ImGuiCol_FrameBg);

    if (!pool.contains(label))
        pool[label] = { state, (state) ? active_color : default_color, {} };

    configuration_t& it = pool[label];
    ImDrawList* draw_list = ImGui::GetWindowDrawList();
    ImVec2 pos = ImGui::GetCursorScreenPos();
    auto now = std::chrono::steady_clock::now();

    float rounding = ImGui::GetStyle().FrameRounding;
    float border_size = ImGui::GetStyle().FrameBorderSize;

    if (state != it.state) {
        it.state = state;
        it.time = now;
    }

    if (animation::is_time_available(it.time))
        it.color = animation::bring_to(it.color, (it.state) ? active_color : default_color, it.time, 100ms);
    
    ImVec2 text_size = ImGui::CalcTextSize(label.c_str());
    ImVec2 text_pos = { pos.x + (size.x - text_size.x) / 2, pos.y + (size.y - text_size.y) / 2 };

    ImGui::Dummy(size);
    
    draw_list->AddRectFilled(pos, { pos.x + size.x, pos.y + size.y }, *it.color, rounding);
    draw_list->AddRect(pos, { pos.x + size.x, pos.y + size.y }, *it.color, rounding, 0, border_size);

    if (it.color.value.alpha <= 128) {
        draw_list->AddText({ text_pos.x + 1, text_pos.y + 1 }, 0xFF000000, label.c_str());
        draw_list->AddText({ text_pos.x - 1, text_pos.y - 1 }, 0xFF000000, label.c_str());
        draw_list->AddText({ text_pos.x + 1, text_pos.y - 1 }, 0xFF000000, label.c_str());
        draw_list->AddText({ text_pos.x - 1, text_pos.y + 1 }, 0xFF000000, label.c_str());
    }

    draw_list->AddText(text_pos, ImGui::GetColorU32(ImGuiCol_Text), label.c_str());
}
