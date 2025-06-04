#ifndef GADMIN_PLUGIN_GUI_ANIMATION_H
#define GADMIN_PLUGIN_GUI_ANIMATION_H

#include <imgui.h>
#include <chrono>
#include "plugin/types/color.h"

namespace plugin::gui::animation {

struct hover_info final {
    std::chrono::steady_clock::time_point time;
    bool state = false;
    auto update() -> void;
}; // struct hover_info final

constexpr auto is_time_available(std::chrono::steady_clock::time_point time) noexcept -> bool;

auto bring_to(float from, float to, std::chrono::steady_clock::time_point start_time,
              std::chrono::milliseconds duration) noexcept -> float;

auto bring_to(const ImVec4& from, const ImVec4& to, std::chrono::steady_clock::time_point start_time,
              std::chrono::milliseconds duration) noexcept -> ImVec4;

auto bring_to(types::color from, types::color to, std::chrono::steady_clock::time_point start_time,
              std::chrono::milliseconds duration) noexcept -> types::color;

auto get_contrast_color(const ImVec4& background, const ImVec4& a = { 0, 0, 0, 1 },
                        const ImVec4& b = { 1, 1, 1, 1 }) noexcept -> ImVec4;

} // namespace plugin::gui::animation

constexpr auto plugin::gui::animation::is_time_available(std::chrono::steady_clock::time_point time)
    noexcept -> bool
{
    return time != std::chrono::steady_clock::time_point {};
}

#endif // GADMIN_PLUGIN_GUI_ANIMATION_H
