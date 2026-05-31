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
#include <type_traits>
#include <chrono>
#include "plugin/types/color.h"
#include "plugin/types/simple.h"

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

/// Switch animation information.
///
/// @tparam T                     Type of the value that will be updated to another during animation.
/// @tparam fade_in_duration_raw  Duration of the fade-in animation in milliseconds.
/// @tparam fade_out_duration_raw Duration of the fade-out animation in milliseconds.
template<typename T,
         types::milliseconds_raw_t fade_in_duration_raw,
         types::milliseconds_raw_t fade_out_duration_raw>
class switch_info final {
public:
    /// Duration of the fade-in animation as `std::chrono::milliseconds`.
    static constexpr std::chrono::milliseconds fade_in_duration
        = std::chrono::milliseconds(fade_in_duration_raw);

    /// Duration of the fade-out animation as `std::chrono::milliseconds`.
    static constexpr std::chrono::milliseconds fade_out_duration
        = std::chrono::milliseconds(fade_out_duration_raw);

    /// Full animation duration as `std::chrono::milliseconds`.
    static constexpr std::chrono::milliseconds fade_in_out_duration
        = fade_in_duration + fade_out_duration;

    /// Callback function type that will be executed after `handle_transition`
    /// call and only after the `fade_in_duration` time.
    using on_change_callback_t = std::function<void(const T& current)>;
private:
    on_change_callback_t on_change_callback = [](const T&) {};
    std::chrono::steady_clock::time_point time;
    std::uint8_t alpha = 255;

    T& current_value;
    T future_value;
public:
    /// Get value of the alpha channel for the elements that uses this animation.
    ///
    /// @note   Requires the call of `handle_animation` method for each frame.
    /// @return Current value of the alpha channel.
    auto get_alpha() const -> float;

    /// Set callback function that will be executed after `handle_transition`
    /// call and only after the `fade_in_duration` time.
    ///
    /// @param new_on_change_callback[in] New callback function.
    auto set_on_change_callback(on_change_callback_t new_on_change_callback) -> void;

    /// Start transition animation from `current_value` to `new_future_value`.
    ///
    /// @note                       Requires the call of `handle_animation` method for each frame.
    /// @param new_future_value[in] New future value (i.e. frame index).
    auto handle_transition(const T& new_future_value) -> void;
    
    /// Handle animation for `fade_in_out_duration` time after `handle_transition`
    /// call: updates alpha channel and current/future values.
    ///
    /// @return True if currently handling the animation.
    auto handle_animation() -> bool;

    /// Construct the class.
    ///
    /// @param current_value[out] Reference to the current value (i.e. frame index).
    explicit switch_info(T& current_value) requires std::is_default_constructible_v<T>
        : current_value(current_value) {}
}; // class switch_info final

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

template<typename T, plugin::types::milliseconds_raw_t _1, plugin::types::milliseconds_raw_t _2>
auto plugin::gui::animation::switch_info<T, _1, _2>::get_alpha() const -> float {
    return alpha / 255.0f;
}

template<typename T, plugin::types::milliseconds_raw_t _1, plugin::types::milliseconds_raw_t _2>
auto plugin::gui::animation::switch_info<T, _1, _2>::set_on_change_callback(on_change_callback_t new_on_change_callback)
    -> void
{
    on_change_callback = new_on_change_callback;
}

template<typename T, plugin::types::milliseconds_raw_t _1, plugin::types::milliseconds_raw_t _2>
auto plugin::gui::animation::switch_info<T, _1, _2>::handle_transition(const T& new_future_value) -> void {
    future_value = new_future_value;
    time = std::chrono::steady_clock::now();
}

template<typename T, plugin::types::milliseconds_raw_t _1, plugin::types::milliseconds_raw_t _2>
auto plugin::gui::animation::switch_info<T, _1, _2>::handle_animation()
    -> bool
{
    auto now = std::chrono::steady_clock::now();

    if (now - time >= fade_in_out_duration)
        return false;
    
    bool change_animation_duration = (now - time >= fade_in_duration);
    std::chrono::milliseconds animation_duration = fade_in_duration;

    if (change_animation_duration) {
        current_value = future_value;
        animation_duration = fade_out_duration;
        on_change_callback(current_value);
    }

    alpha = bring_to(alpha, change_animation_duration * 255.0f, time, animation_duration);

    return true;
}

#endif // GADMIN_PLUGIN_GUI_ANIMATION_H
