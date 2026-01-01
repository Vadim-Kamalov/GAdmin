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

#ifndef GADMIN_PLUGIN_GUI_ANIMATION_H
#define GADMIN_PLUGIN_GUI_ANIMATION_H

#include <imgui.h>
#include <chrono>
#include "plugin/types/color.h"

namespace plugin::gui::animation {

/// Hover animation information.
struct hover_info final {
    /// Time when hovered.
    std::chrono::steady_clock::time_point time;
    
    /// Current hover state.
    bool state = false;

    /// Update hover information.
    auto update() -> void;
}; // struct hover_info final

/// Check if `time` is available (not equal to zero).
///
/// @param time[in] Time to check.
/// @return         True if `time` is available.
constexpr auto is_time_available(std::chrono::steady_clock::time_point time) noexcept -> bool;

/// Bring `from` to `to` based on the current time minus `start_time` and `duration`.
///
/// @param from[in]       Initial value.
/// @param to[in]         Maximum value of the transition.
/// @param start_time[in] Transition initial time.
/// @param duration[in]   Transition duration.
auto bring_to(float from, float to, std::chrono::steady_clock::time_point start_time,
              std::chrono::milliseconds duration) noexcept -> float;

/// Bring `from` to `to` based on the current time minus `start_time` and `duration`.
///
/// @param from[in]       Initial value.
/// @param to[in]         Maximum value of the transition.
/// @param start_time[in] Transition initial time.
auto bring_to(const ImVec4& from, const ImVec4& to, std::chrono::steady_clock::time_point start_time,
              std::chrono::milliseconds duration) noexcept -> ImVec4;

/// Bring `from` to `to` based on the current time minus `start_time` and `duration`.
///
/// @param from[in]       Initial value.
/// @param to[in]         Maximum value of the transition.
/// @param start_time[in] Transition initial time.
auto bring_to(types::color from, types::color to, std::chrono::steady_clock::time_point start_time,
              std::chrono::milliseconds duration) noexcept -> types::color;

/// Get contrast color (`a` or `b`) based on the background.
///
/// @param background[in] Background color.
/// @param a[in]          Dark color.
/// @param b[in]          White color.
/// @return               Contrast color (`a` or `b`) based on the background.
auto get_contrast_color(const ImVec4& background, const ImVec4& a = { 0, 0, 0, 1 },
                        const ImVec4& b = { 1, 1, 1, 1 }) noexcept -> ImVec4;

} // namespace plugin::gui::animation

constexpr auto plugin::gui::animation::is_time_available(std::chrono::steady_clock::time_point time)
    noexcept -> bool
{
    return time != std::chrono::steady_clock::time_point {};
}

#endif // GADMIN_PLUGIN_GUI_ANIMATION_H
