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

#ifndef GADMIN_PLUGIN_GUI_WIDGETS_ALIGNER_H
#define GADMIN_PLUGIN_GUI_WIDGETS_ALIGNER_H

#include <nlohmann/json.hpp>
#include <imgui.h>

namespace plugin::gui::widgets {

/// Widget for aligning items based on the align mode passed.
class aligner final {
public:
    /// Align mode.
    enum class mode_t : std::uint8_t {
        left,   ///< Align on the left side of the window.
        center, ///< Align on the center of the window.
        right   ///< Align on the right side of the window.
    }; // enum class mode_t : std::uint8_t
private:
    mode_t mode = mode_t::left;
    float item_width = 0.0f;
public:
    /// Align next item based on the align mode and item width passed.
    /// 
    /// @param start[in] Position when should align on the left side of the window.
    auto align_next_item(float start = ImGui::GetStyle().WindowPadding.x) const -> void;
    
    /// Construct aligner widget.
    ///
    /// @param mode[in]       Align mode: left, center or right.
    /// @param item_width[in] Width of the next item that should be aligned.
    explicit aligner(const mode_t& mode, float item_width)
        : mode(mode), item_width(item_width) {}
    
    aligner() = default;
}; // class aligner final

NLOHMANN_JSON_SERIALIZE_ENUM(aligner::mode_t, {
    { aligner::mode_t::left, "left" },
    { aligner::mode_t::center, "center" },
    { aligner::mode_t::right, "right" }
}) // NLOHMANN_JSON_SERIALIZE_ENUM(aligner::mode_t, { ... })

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_ALIGNER_H
