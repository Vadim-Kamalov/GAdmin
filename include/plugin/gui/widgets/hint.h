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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_GUI_WIDGETS_HINT_H
#define GADMIN_PLUGIN_GUI_WIDGETS_HINT_H

#include "plugin/types/color.h"
#include <imgui.h>
#include <string>
#include <chrono>
#include <functional>
#include <unordered_map>

using namespace std::chrono_literals;

namespace plugin::gui::widgets {

/// Represents a GUI hint opened on the previous item after
/// certain condition(s) with customizable properties.
class hint final {
public:
    using condition_t = std::function<bool()>;  ///< Condition to show the hint.
    using renderer_t = std::function<void()>;   ///< Render function for the hint.
private:
    struct configuration_t final {
        float width;
        bool opened;
        std::chrono::steady_clock::time_point time;
    }; // struct configuration_t final
    
    static inline std::unordered_map<std::string, configuration_t> pool;
    
    std::string label;

    renderer_t renderer = std::bind(&hint::default_renderer, this);
    condition_t condition = []{ return ImGui::IsItemHovered(); };

    std::chrono::milliseconds show_hide_duration = 200ms;
    types::color color = ImGui::GetColorU32(ImGuiCol_FrameBg);

    bool using_custom_condition = false;
    bool using_custom_renderer = false;

    auto default_renderer() const -> void;
    auto render_hint(float alpha) const -> void;
public:
    /// Set the condition for showing the hint.
    /// 
    /// @param new_condition[in] New condition to set.
    /// @return                  Reference to the hint object to allow construction be chain-called.
    inline auto with_condition(condition_t new_condition) noexcept -> hint&;

    /// Set the show/hide duration for the hint.
    /// 
    /// @param duration[in] Duration to set.
    /// @return             Reference to the hint object to allow construction be chain-called.
    inline auto with_show_hide_duration(std::chrono::milliseconds duration) noexcept -> hint&;

    /// Set the renderer for the hint.
    /// 
    /// @param new_renderer[in] New renderer to set.
    /// @return                 Reference to the hint object to allow construction be chain-called.
    inline auto with_renderer(renderer_t new_renderer) noexcept -> hint&;

    /// Render the hint. 
    auto render() -> void;

    /// Render the hint as a guide: it will be appeared only once until the configuration file is reset.
    /// 
    /// @param label[in]              Label of the hint.
    /// @param optional_condition[in] Optional condition for rendering the hint.
    static auto render_as_guide(const std::string& label, bool optional_condition = true) noexcept -> void;

    /// Construct the hint.
    ///
    /// @param label[in] Label of the hint.
    explicit hint(const std::string_view& label)
        : label(std::move(label)) {}

    /// Construct the hint with the new background color of it.
    ///
    /// @param label[in] Label of the hint.
    /// @param color[in] Color of the hint.
    explicit hint(const std::string_view& label, const types::color& color)
        : label(std::move(label)), color(color) {}
}; // class hint final

} // namespace plugin::gui::widgets

inline auto plugin::gui::widgets::hint::with_condition(condition_t new_condition) noexcept -> hint& {
    condition = new_condition;
    using_custom_condition = true;
    return *this;
}

inline auto plugin::gui::widgets::hint::with_show_hide_duration(std::chrono::milliseconds duration) noexcept -> hint& {
    show_hide_duration = duration;
    return *this;
}

inline auto plugin::gui::widgets::hint::with_renderer(renderer_t new_renderer) noexcept -> hint& {
    renderer = new_renderer;
    using_custom_renderer = true;
    return *this;
}

#endif // GADMIN_PLUGIN_GUI_WIDGETS_HINT_H
