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

#ifndef GADMIN_PLUGIN_GUI_WIDGETS_TOGGLE_BUTTON_H
#define GADMIN_PLUGIN_GUI_WIDGETS_TOGGLE_BUTTON_H

#include "plugin/types/color.h"
#include "plugin/types/setter.h"
#include <imgui.h>
#include <chrono>
#include <unordered_map>

using namespace std::chrono_literals;

namespace plugin::gui::widgets {

/// Represents a toggle button in the GUI.
class toggle_button final {
private:
    static constexpr float radius = 6;
    static constexpr ImVec2 size = { 40, 20 };
    static constexpr std::chrono::milliseconds duration = 300ms;
    
    struct configuration_t {
        std::chrono::steady_clock::time_point time;
        types::color color;
        float pos_x;
    }; // struct configuration_t
    
    static inline std::unordered_map<std::string, configuration_t> pool;

    std::string label;
    types::setter<bool> state;
public:
    /// Render the toggle button.
    /// 
    /// @return True if the button was clicked by the user.
    auto render() -> bool;

    /// Construct toggle button with a directly passed state by reference.
    /// 
    /// @param label[in] Label of the toggle button.
    /// @param state[in] State of the toggle button.
    explicit toggle_button(const std::string_view& label, bool& state)
        : label(std::move(label)), state(state) {}

    /// Construct toggle button with a setter.
    ///
    /// @param label[in] Label of the toggle button.
    /// @param state[in] Setter for the state of the toggle button.
    explicit toggle_button(const std::string_view& label, const types::setter<bool>& state)
        : label(std::move(label)), state(std::move(state)) {}
}; // class toggle_button final

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_TOGGLE_BUTTON_H
