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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_GUI_WIDGETS_BUTTON_H
#define GADMIN_PLUGIN_GUI_WIDGETS_BUTTON_H

#include "plugin/gui/animation.h"
#include <optional>
#include <string>
#include <utility>
#include <unordered_map>
#include <imgui.h>
#include <chrono>

using namespace std::chrono_literals;

namespace plugin::gui::widgets {

/// Represents a GUI button with ripple animation on click and border highligting while hovered.
class button final {
private:
    struct configuration_t final {
        animation::hover_info hovered;
        std::uint8_t border_alpha = 0;
        float alpha = 0, radius = 0;
        std::optional<ImVec2> click_position;
        std::chrono::steady_clock::time_point click_time;
    }; // struct configuration_t final
    
    std::array<std::chrono::milliseconds, 3> durations = { 200ms, 400ms, 300ms };
    std::string id;

    ImVec2 size;
    ImDrawFlags draw_flags = ImDrawFlags_RoundCornersAll;

    static inline std::unordered_map<std::string, configuration_t> pool;
   
    auto register_in_pool() const -> void;
public:
    std::string label;

    /// Set the draw flags for the button.
    /// 
    /// @param new_draw_flags[in] New draw flags to set.
    /// @return                   Reference to the button object to allow construction be chain-called.
    inline auto with_draw_flags(ImDrawFlags new_draw_flags) noexcept -> button&;

    /// Set the animation durations for the button.
    /// 
    /// @param new_durations[in] New durations to set.
    /// @return                  Reference to the button object to allow construction be chain-called.
    inline auto with_durations(const std::array<std::chrono::milliseconds, 3>& durations) noexcept -> button&;

    /// Render the button.
    /// 
    /// @return True if the button was clicked.
    auto render() -> bool;

    /// Construct button with pre-computed size and label.
    ///
    /// @note Button's ID can be passed in label after double-hashtag in label. e.g. "Hello!##my_button_id".
    /// @param label[in] Label of the button.
    explicit button(const std::string_view& label);

    /// Construct button with an ID, label and size.
    /// 
    /// @note            Button's ID can be passed in label after double-hashtag in label. e.g. "Hello!##my_button_id".
    /// @param label[in] Label of the button.
    /// @param id[in]    ID of the button.
    /// @param size[in]  Size of the button.
    explicit button(const std::string_view& label, const std::string_view& id, const ImVec2& size)
        : label(std::move(label)), size(std::move(size)), id(std::move(id)) { register_in_pool(); }

    /// Construct button with a size.
    /// 
    /// @note            Button's ID can be passed in label after double-hashtag in label. e.g. "Hello!##my_button_id".
    /// @param label[in] Label of the button.
    /// @param size[in]  Size of the button.
    explicit button(const std::string_view& label, const ImVec2& size)
        : label(std::move(label)), size(std::move(size)), id(std::move(label)) { register_in_pool(); }

    button() = default;
}; // class button final

} // namespace plugin::gui::widgets

inline auto plugin::gui::widgets::button::with_draw_flags(ImDrawFlags new_draw_flags) noexcept -> button& {
    draw_flags = new_draw_flags;
    return *this;
}

inline auto plugin::gui::widgets::button::with_durations(const std::array<std::chrono::milliseconds, 3>& new_durations)
    noexcept -> button&
{
    durations = std::move(new_durations);
    return *this;
}

#endif // GADMIN_PLUGIN_GUI_WIDGETS_BUTTON_H
