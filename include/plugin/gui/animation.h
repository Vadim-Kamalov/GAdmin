#ifndef GADMIN_PLUGIN_GUI_ANIMATION_H
#define GADMIN_PLUGIN_GUI_ANIMATION_H

#include <cstdint>
#include <imgui.h>
#include <chrono>
#include "plugin/utils.h"

namespace plugin::gui::animation {

constexpr bool is_time_available(std::chrono::steady_clock::time_point time) noexcept;

float bring_to(float from, float to,
               std::chrono::steady_clock::time_point start_time,
               std::chrono::milliseconds duration) noexcept;

ImVec4 bring_to(const ImVec4& from, const ImVec4& to,
                std::chrono::steady_clock::time_point start_time,
                std::chrono::milliseconds duration) noexcept;

utils::color_abgr_t bring_to(utils::color_abgr_t from, utils::color_abgr_t to,
                             std::chrono::steady_clock::time_point start_time,
                             std::chrono::milliseconds duration) noexcept;

ImVec4 get_contrast_color(const ImVec4& background,
                          const ImVec4& a = { 0, 0, 0, 1 },
                          const ImVec4& b = { 1, 1, 1, 1 }) noexcept;

constexpr utils::color_abgr_t get_alpha_changed_color(utils::color_abgr_t color, std::uint8_t alpha) noexcept;

} // namespace plugin::gui::animation

constexpr bool
plugin::gui::animation::is_time_available(std::chrono::steady_clock::time_point time) noexcept {
    return time != std::chrono::steady_clock::time_point {};
}

constexpr plugin::utils::color_abgr_t
plugin::gui::animation::get_alpha_changed_color(utils::color_abgr_t color, std::uint8_t alpha) noexcept {
    return (color & 0x00FFFFFF) | (alpha << 24);
}

#endif // GADMIN_PLUGIN_GUI_ANIMATION_H
