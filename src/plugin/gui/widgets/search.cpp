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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#include "plugin/gui/widgets/search.h"
#include "plugin/string_utils.h"
#include <imgui.h>
#include <misc/cpp/imgui_stdlib.h>

auto plugin::gui::widgets::search::render(float width, const std::string_view& placeholder) -> void {
    if (width != 0)
        ImGui::SetNextItemWidth(width);

    ImGui::InputTextWithHint(("##" + id).c_str(), std::string(placeholder).c_str(), &buffer);
}

auto plugin::gui::widgets::search::clear() -> void {
    buffer.clear();
}

auto plugin::gui::widgets::search::contains(const std::string_view& text) const -> bool {
    if (empty())
        return true;

    std::string text_lower = string_utils::to_lowercase(text);
    std::string buffer_lower = string_utils::to_lowercase(buffer);

    return text_lower.contains(buffer_lower);
}

auto plugin::gui::widgets::search::empty() const -> bool {
    return buffer.empty();
}

auto plugin::gui::widgets::search::get_text() const -> std::string {
    return buffer;
}

auto plugin::gui::widgets::search::set_text(const std::string_view& text) -> void {
    buffer = text;
}
