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

#include "plugin/gui/animation.h"

auto plugin::gui::animation::hover_info::update() -> void {
    bool hovered = ImGui::IsItemHovered();

    if (hovered == state)
        return;

    state = hovered;
    time = std::chrono::steady_clock::now();
}

auto plugin::gui::animation::bring_to(float from, float to, std::chrono::steady_clock::time_point start_time,
                                      std::chrono::milliseconds duration) noexcept -> float
{
    auto now = std::chrono::steady_clock::now();
    auto timer = std::chrono::duration_cast<std::chrono::milliseconds>(now - start_time).count();

    if (timer >= 0 && timer <= duration.count()) {
        float count = static_cast<float>(timer) / (static_cast<float>(duration.count()) / 100);
        return from + (count * (to - from) / 100);
    }

    return (timer > duration.count()) ? to : from;
}

auto plugin::gui::animation::bring_to(const ImVec4& from, const ImVec4& to, std::chrono::steady_clock::time_point start_time,
                                      std::chrono::milliseconds duration) noexcept -> ImVec4
{
    auto now = std::chrono::steady_clock::now();
    auto timer = std::chrono::duration_cast<std::chrono::milliseconds>(now - start_time).count();

    if (timer >= 0 && timer <= duration.count()) {
        float count = static_cast<float>(timer) / (static_cast<float>(duration.count()) / 100);
        return {
            from.x + (count * (to.x - from.x) / 100),
            from.y + (count * (to.y - from.y) / 100),
            from.z + (count * (to.z - from.z) / 100),
            from.w + (count * (to.w - from.w) / 100)
        };
    }

    return (timer > duration.count()) ? to : from;
}

auto plugin::gui::animation::bring_to(types::color from, types::color to, std::chrono::steady_clock::time_point start_time,
                                      std::chrono::milliseconds duration) noexcept -> types::color
{
    auto now = std::chrono::steady_clock::now();
    auto timer = std::chrono::duration_cast<std::chrono::milliseconds>(now - start_time).count();

    if (timer >= 0 && timer <= duration.count()) {
        float count = static_cast<float>(timer) / (static_cast<float>(duration.count()) / 100);

        std::uint8_t a = static_cast<std::uint8_t>(from.value.alpha + (count * (to.value.alpha - from.value.alpha) / 100));
        std::uint8_t b = static_cast<std::uint8_t>(from.value.blue + (count * (to.value.blue - from.value.blue) / 100));
        std::uint8_t g = static_cast<std::uint8_t>(from.value.green + (count * (to.value.green - from.value.green) / 100));
        std::uint8_t r = static_cast<std::uint8_t>(from.value.red + (count * (to.value.red - from.value.red) / 100));

        return types::color::abgr(a, r, g, b);
    }

    return (timer > duration.count()) ? to : from;
}

auto plugin::gui::animation::get_contrast_color(const ImVec4& background, const ImVec4& a, const ImVec4& b)
    noexcept -> ImVec4
{
    return ((1 - (0.299 * background.x + 0.587 * background.y + 0.114 * background.z)) < 0.5) ? a : b;
}
