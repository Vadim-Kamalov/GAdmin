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

#include "plugin/gui/windows/main/frames/home.h"
#include "plugin/gui/windows/main/widgets/frame_selector.h"
#include "plugin/gui/windows/main/widgets/frame_selector_toggle.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/gui/widgets/text_button.h"
#include "plugin/plugin.h"

auto plugin::gui::windows::main::frames::home::convert_time(const std::time_t& time) const -> std::string {
    std::tm tm = *std::localtime(&time);

    return std::format("{:02d}.{:02d}.{:04d} {:02d}:{:02d}:{:02d}", tm.tm_mday, tm.tm_mon + 1,
                       tm.tm_year + 1900, tm.tm_hour, tm.tm_min, tm.tm_sec);
}

auto plugin::gui::windows::main::frames::home::get_greeting_text() const -> std::string {
    std::time_t now_time_t = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());

    switch (std::localtime(&now_time_t)->tm_hour) {
        case 6 ... 11: return "Доброе утро, ";
        case 12 ... 18: return "Добрый день, ";
        case 19 ... 23: return "Добрый вечер, ";
        default: return "Доброй ночи, ";
    }
}

auto plugin::gui::windows::main::frames::home::render_line(const line_t& line) const -> void {
    float left_width = line.left.font->CalcTextSizeA(lines_font_size, FLT_MAX, 0.0f, line.left.text.c_str()).x;
    float right_width = line.right.font->CalcTextSizeA(lines_font_size, FLT_MAX, 0.0f, line.right.text.c_str()).x;

    ImGui::SetCursorPosX((ImGui::GetContentRegionAvail().x - left_width - right_width) / 2.0f);
    ImGui::BeginGroup();
    {
        gui::widgets::text(line.left.font, lines_font_size, 0, "{}", line.left.text);
        ImGui::SameLine(0.0f, 0.0f);
        gui::widgets::text(line.right.font, lines_font_size, 0, "{}", line.right.text);
    }
    ImGui::EndGroup();
}

auto plugin::gui::windows::main::frames::home::render_title() const -> void {
    float spacing_y = ImGui::GetStyle().ItemSpacing.y;
    std::string user_nickname = (*configuration)["user"]["nickname"];

    ImGui::SetCursorPosY((ImGui::GetWindowHeight() - (lines_font_size + spacing_y) * lines_count - spacing_y) / 2.0f);
    ImGui::BeginGroup();
    {
        render_line({{ bold_font, "GAdmin " }, { light_font, "v" PROJECT_VERSION }});
        render_line({{ bold_font, get_greeting_text() }, { regular_font, user_nickname + "!" }});
        render_line({{ bold_font, "Последний вход: " }, { regular_font, last_time_join }});
    }
    ImGui::EndGroup();
}

auto plugin::gui::windows::main::frames::home::render_legal_notice() const -> void {
    ImGui::SetCursorPosY(ImGui::GetWindowHeight() - legal_notice_font_size * 2
            - ImGui::GetStyle().ItemSpacing.y - ImGui::GetStyle().WindowPadding.y);

    ImGui::BeginGroup();
    {
        ImGui::PushFont(light_font, legal_notice_font_size);
        {
            for (const auto& text : legal_notice_text) {
                ImGui::SetCursorPosX((ImGui::GetContentRegionAvail().x - ImGui::CalcTextSize(text).x) / 2.0f);
                ImGui::TextUnformatted(text);
            }
        }
        ImGui::PopFont();
    }
    ImGui::EndGroup();
}

auto plugin::gui::windows::main::frames::home::render() -> void {
    ImGui::SetCursorPosX((ImGui::GetContentRegionAvail().x - ImGui::CalcTextSize(links_text).x) / 2.0f);
    ImGui::BeginGroup();
    {
        ImGui::PushFont(light_font, top_bottom_font_size);
        {
            if (gui::widgets::text_button("Репозиторий GitHub").render())
                ImGui::GetPlatformIO().Platform_OpenInShellFn(ImGui::GetCurrentContext(), PROJECT_REPOSITORY);

            ImGui::SameLine(0.0f, 0.0f);
            ImGui::TextUnformatted(" · ");
            ImGui::SameLine(0.0f, 0.0f);
            
            if (gui::widgets::text_button("Тема на форуме").render())
                ImGui::GetPlatformIO().Platform_OpenInShellFn(ImGui::GetCurrentContext(), "https://forum.gambit-rp.ru/threads/485600");
        }
        ImGui::PopFont();
    }
    ImGui::EndGroup();
    render_title();

    float end_y = ImGui::GetItemRectMax().y;

    render_legal_notice();
    ImGui::PushFont(light_font, button_font_size);
    {
        ImVec2 button_text_size = ImGui::CalcTextSize(button_text);

        ImGui::SetCursorScreenPos({ ImGui::GetWindowPos().x + (ImGui::GetWindowWidth() - button_text_size.x) / 2.0f,
                                    end_y + (ImGui::GetItemRectMin().y - end_y - button_text_size.y) / 2.0f });

        if (gui::widgets::text_button(button_text).render()) {
            auto& frame_selector = widgets::frame_selector::instance(child);
            auto& frame_selector_toggle = widgets::frame_selector_toggle::instance(&frame_selector);
            frame_selector_toggle.switch_menu_state();
        }
    }
    ImGui::PopFont();
}

plugin::gui::windows::main::frames::home::home(types::not_null<initializer*> child)
    : child(child),
      bold_font(child->child->fonts->bold),
      regular_font(child->child->fonts->regular),
      light_font(child->child->fonts->light)
{
    std::time_t now_time_t = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    auto& saved_time_t = (*configuration)["internal"]["last_time_join"];

    last_time_join = convert_time((saved_time_t == 0) ? now_time_t : std::time_t(saved_time_t));
    saved_time_t = now_time_t;
}
