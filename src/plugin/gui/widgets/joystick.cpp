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

#include "plugin/gui/widgets/joystick.h"
#include "plugin/gui/animation.h"
#include "plugin/types/color.h"

using namespace std::chrono_literals;

auto plugin::gui::widgets::joystick::update(std::uint16_t x, std::uint16_t y) -> void {
    auto now = std::chrono::steady_clock::now();

    if (now - time < 100ms)
        return;

    time = now;
    old = current;
    current.x = (x == 0) ? 0 : ((x > 128) ? x - 0xFFFF : x);
    current.y = (y == 0) ? 0 : ((y > 128) ? y - 0xFFFF : y);
}

auto plugin::gui::widgets::joystick::render() const -> void {
    ImDrawList* draw_list = ImGui::GetWindowDrawList();

    types::color color = ImGui::GetColorU32(ImGuiCol_FrameBg);
    types::color background = types::color(color, 76);

    ImVec2 pos = ImGui::GetCursorScreenPos();
    ImVec2 center = { pos.x + radius, pos.y + radius };

    draw_list->AddCircleFilled(center, radius, *background, 0x30);
    draw_list->AddCircle(center, radius, *color, 0x30, ImGui::GetStyle().FrameBorderSize);
    
    float x = 0, y = 0;

    if (animation::is_time_available(time)) {
        x = animation::bring_to((old.x / 100) * 13.5f, (current.x / 100) * 13.5f, time, 100ms);
        y = animation::bring_to((old.y / 100) * 13.5f, (current.y / 100) * 13.5f, time, 100ms);
    }

    draw_list->AddCircleFilled({ center.x + x, center.y + y }, dot_radius, *color, 0xF);

    ImGui::Dummy({ radius * 2, radius * 2 });
}
