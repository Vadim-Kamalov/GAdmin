#ifndef GADMIN_PLUGIN_GUI_ANIMATION_H
#define GADMIN_PLUGIN_GUI_ANIMATION_H

#include <imgui.h>
#include <chrono>

namespace plugin::gui::animation {

float bring_to(float from, float to, std::chrono::steady_clock::time_point start_time, std::chrono::milliseconds duration) noexcept;
ImVec4 bring_to(const ImVec4& from, const ImVec4& to, std::chrono::steady_clock::time_point start_time, std::chrono::milliseconds duration) noexcept;

constexpr bool
time_available(std::chrono::steady_clock::time_point time) noexcept {
    return time != std::chrono::steady_clock::time_point {};
}

} // namespace plugin::gui::animation

#endif // GADMIN_PLUGIN_GUI_ANIMATION_H
