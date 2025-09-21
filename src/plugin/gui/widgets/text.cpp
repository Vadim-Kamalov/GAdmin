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

#include "plugin/gui/widgets/text.h"
#include <imgui_internal.h>

static auto render_border(const ImVec2& pos, const ImVec4& border_color, std::uint8_t border_size, plugin::types::zstring_t text)
    noexcept -> void
{
    ImDrawList* draw_list = ImGui::GetWindowDrawList();
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    ImFont* font = draw_list->_Data->Font;
    float font_size = draw_list->_Data->FontSize;

    // imgui.h does not provide any way to get the current text wrap position without using imgui_internal.h
    float wrap_width = ImGui::CalcWrapWidthForPos(window->DC.CursorPos, window->DC.TextWrapPos);
    ImU32 text_color = ImGui::ColorConvertFloat4ToU32(border_color);

    for (std::uint8_t i = 1; i <= border_size; i++) {
        draw_list->AddText(font, font_size, { pos.x + i, pos.y }, text_color, text, nullptr, wrap_width);
        draw_list->AddText(font, font_size, { pos.x - i, pos.y }, text_color, text, nullptr, wrap_width);
        draw_list->AddText(font, font_size, { pos.x, pos.y + i }, text_color, text, nullptr, wrap_width);
        draw_list->AddText(font, font_size, { pos.x, pos.y - i }, text_color, text, nullptr, wrap_width);
    }
}

auto plugin::gui::widgets::basic_text::render() const -> void {
    if (font)
        ImGui::PushFont(font, font_size);

    render_border(ImGui::GetCursorScreenPos(), colors.border, border_size, text);
    ImGui::TextColored(colors.text, "%s", text);

    if (font)
        ImGui::PopFont();
}
