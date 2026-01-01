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

#ifndef GADMIN_PLUGIN_GUI_WIDGETS_KEYCAP_H
#define GADMIN_PLUGIN_GUI_WIDGETS_KEYCAP_H

#include <chrono>
#include <string>
#include <utility>
#include <unordered_map>
#include <imgui.h>
#include "plugin/types/color.h"

namespace plugin::gui::widgets {

/// Represents a keycap in the GUI.
class keycap final {
private:
    std::string label;
    ImVec2 size;
    bool state;
    
    struct configuration_t final {
        bool state;
        types::color color;
        std::chrono::steady_clock::time_point time;
    }; // struct configuration_t final

    static inline std::unordered_map<std::string, configuration_t> pool;
public:
    /// Render the keycap.
    auto render() const -> void;

    /// Constructor for the keycap class.
    /// 
    /// @param label[in] Label of the keycap.
    /// @param size[in]  Size of the keycap.
    /// @param state[in] State of the keycap.
    explicit keycap(const std::string_view& label, const ImVec2& size, bool state)
        : label(std::move(label)), size(std::move(size)), state(state) {}
}; // class keycap final

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_KEYCAP_H
