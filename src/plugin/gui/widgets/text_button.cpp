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

#include "plugin/gui/widgets/text_button.h"
#include "plugin/gui/animation.h"
#include "plugin/string_utils.h"
#include <imgui.h>

auto plugin::gui::widgets::text_button::render() const -> bool {
    configuration_t& it = pool[label];
    ImDrawList* draw_list = ImGui::GetWindowDrawList();
    ImVec2 pos = ImGui::GetCursorScreenPos();

    ImGui::TextUnformatted(string_utils::truncate_until_hashtag(label).c_str());
    it.hover_info.update();

    it.alpha = animation::bring_to(it.alpha, static_cast<float>(it.hover_info.state),
                                   it.hover_info.time, animation_duration);

    std::uint32_t color = ImGui::GetColorU32(ImGuiCol_Text);

    if (!it.hover_info.state)
        color = (color & 0x00FFFFFF) | (static_cast<std::uint32_t>(it.alpha * 255.0f) << 24);

    ImVec2 size = ImGui::GetItemRectSize();
    float max = size.x / 2.0f;
    float mid = pos.x + max;
    float y = pos.y + size.y + line_height;

    draw_list->AddLine({ mid, y }, { mid + (max * it.alpha), y }, color, line_height);
    draw_list->AddLine({ mid, y }, { mid - (max * it.alpha), y }, color, line_height);

    return ImGui::IsItemClicked();
}

plugin::gui::widgets::text_button::text_button(const std::string_view& label_view)
    : label(std::move(label_view))
{
    if (pool.contains(label))
        return;

    pool[label] = {};
}
