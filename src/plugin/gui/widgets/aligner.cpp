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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#include "plugin/gui/widgets/aligner.h"
#include <imgui.h>

auto plugin::gui::widgets::aligner::align_next_item(float start) const -> void {
    std::int32_t pos_x = start; // std::int32_t to avoid any float/double precision problems

    switch (mode) {
        case mode_t::left:
            break;
        case mode_t::center:
            pos_x = (ImGui::GetContentRegionAvail().x - item_width) / 2;
            break;
        case mode_t::right:
            pos_x = ImGui::GetContentRegionAvail().x - item_width;
            break;
    }

    ImGui::SetCursorPosX(pos_x);
}
