/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2024-2025 The Contributors.
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

/// @file include/plugin/gui/widgets/hint.h
/// @details Provides functionality for creating and managing GUI hints.

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

/// @class hint
/// @brief Represents a GUI hint with customizable properties.
class hint {
public:
/// @brief Function type for the condition to show the hint.
    using condition_t = std::function<bool()>;
    using renderer_t = std::function<void()>;
private:
    std::string label;

    renderer_t renderer = std::bind(&hint::default_renderer, this);
    condition_t condition = []{ return ImGui::IsItemHovered(); };

    std::chrono::milliseconds show_hide_duration = 200ms;
    types::color color = ImGui::GetColorU32(ImGuiCol_FrameBg);

    bool using_custom_condition = false;
    bool using_custom_renderer = false;

    void default_renderer() const;
    void render_hint(float alpha) const;
private:
    struct configuration_t {
        float width;
        bool opened;
        std::chrono::steady_clock::time_point time;
    }; // struct configuration_t
    
    static inline std::unordered_map<std::string, configuration_t> pool;
public:
/// @brief Sets the condition for showing the hint.
/// @param new_condition The new condition to set.
/// @return Reference to the hint object.
    inline hint& with_condition(condition_t new_condition) noexcept;
/// @brief Sets the show/hide duration for the hint.
/// @param duration The duration to set.
/// @return Reference to the hint object.
    inline hint& with_show_hide_duration(std::chrono::milliseconds duration) noexcept;
/// @brief Sets the renderer for the hint.
/// @param new_renderer The new renderer to set.
/// @return Reference to the hint object.
    inline hint& with_renderer(renderer_t new_renderer) noexcept;

    void render();

/// @brief Renders the hint as a guide.
/// @param label The label of the hint.
/// @param optional_condition Optional condition for rendering the hint.
    static void render_as_guide(const std::string& label, bool optional_condition = true) noexcept;

/// @brief Constructor for the hint class.
/// @param label The label of the hint.
    explicit hint(const std::string_view& label)
        : label(std::move(label)) {}

/// @brief Constructor for the hint class with a color.
/// @param label The label of the hint.
/// @param color The color of the hint.
    explicit hint(const std::string_view& label, const types::color& color)
        : label(std::move(label)), color(color) {}
}; // class hint

} // namespace plugin::gui::widgets

/// @brief Sets the condition for showing the hint.
/// @param new_condition The new condition to set.
/// @return Reference to the hint object.
inline plugin::gui::widgets::hint&
plugin::gui::widgets::hint::with_condition(condition_t new_condition) noexcept {
    condition = new_condition;
    using_custom_condition = true;
    return *this;
}

/// @brief Sets the show/hide duration for the hint.
/// @param duration The duration to set.
/// @return Reference to the hint object.
inline plugin::gui::widgets::hint&
plugin::gui::widgets::hint::with_show_hide_duration(std::chrono::milliseconds duration) noexcept {
    show_hide_duration = duration;
    return *this;
}

/// @brief Sets the renderer for the hint.
/// @param new_renderer The new renderer to set.
/// @return Reference to the hint object.
inline plugin::gui::widgets::hint&
plugin::gui::widgets::hint::with_renderer(renderer_t new_renderer) noexcept {
    renderer = new_renderer;
    using_custom_renderer = true;
    return *this;
}

#endif // GADMIN_PLUGIN_GUI_WIDGETS_HINT_H
