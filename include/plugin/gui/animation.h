#ifndef GADMIN_PLUGIN_GUI_ANIMATION_H
#define GADMIN_PLUGIN_GUI_ANIMATION_H

#include <imgui.h>
#include <chrono>
#include "plugin/types/color.h"

namespace plugin::gui::animation {

constexpr bool is_time_available(std::chrono::steady_clock::time_point time) noexcept;

float bring_to(float from, float to,
               std::chrono::steady_clock::time_point start_time,
               std::chrono::milliseconds duration) noexcept;

ImVec4 bring_to(const ImVec4& from, const ImVec4& to,
                std::chrono::steady_clock::time_point start_time,
                std::chrono::milliseconds duration) noexcept;

types::color bring_to(types::color from, types::color to,
                      std::chrono::steady_clock::time_point start_time,
                      std::chrono::milliseconds duration) noexcept;

ImVec4 get_contrast_color(const ImVec4& background,
                          const ImVec4& a = { 0, 0, 0, 1 },
                          const ImVec4& b = { 1, 1, 1, 1 }) noexcept;

} // namespace plugin::gui::animation

constexpr bool
plugin::gui::animation::is_time_available(std::chrono::steady_clock::time_point time) noexcept {
    return time != std::chrono::steady_clock::time_point {};
}

#endif // GADMIN_PLUGIN_GUI_ANIMATION_H
