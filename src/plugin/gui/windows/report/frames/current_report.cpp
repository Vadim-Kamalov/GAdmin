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

#include "plugin/gui/windows/report/frames/current_report.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/gui/widgets/hint.h"
#include "plugin/gui/style.h"
#include "plugin/gui/icon.h"
#include "plugin/server/user.h"
#include "plugin/string_utils.h"
#include "plugin/plugin.h"
#include <misc/cpp/imgui_stdlib.h>

auto plugin::gui::windows::report::frames::current_report::hint_renderer() -> void {
    static constexpr int block_time_options[4] = { 10, 30, 60, 90 };

    if (!ImGui::IsWindowHovered() && ImGui::IsMouseClicked(ImGuiMouseButton_Left))
        hint_active = false;

    ImGui::PushFont(bold_font);
    {
        ImGui::TextUnformatted("Выберите время блокировки");
    }
    ImGui::PopFont();

    ImVec2 button_size = { ImGui::GetContentRegionAvail().x, ImGui::GetFrameHeight() };

    for (const auto& [ index, minutes ] : block_time_options | std::views::enumerate) {
        if (!widgets::button(std::to_string(minutes) + " минут", button_size).render() || !hint_active)
            continue;

        child->network.block_report(child->controls.current_report_frame_details.answer_input, index);
        hint_active = false;
    }

    ImGui::PushFont(bold_font);
    {
        if (widgets::button("Отмена##current_report::hint_renderer", button_size).render())
            hint_active = true;
    }
    ImGui::PopFont();
}

auto plugin::gui::windows::report::frames::current_report::get_report_active_time() const -> std::string {
    auto duration = std::chrono::steady_clock::now() - child->network.active_report->time_taken;
    auto minutes = std::chrono::duration_cast<std::chrono::minutes>(duration);
    
    duration -= minutes;
    
    auto seconds = std::chrono::duration_cast<std::chrono::seconds>(duration);

    return std::format("{:02}:{:02}", minutes.count(), seconds.count());
}

auto plugin::gui::windows::report::frames::current_report::verify_user_input() -> bool {
    std::string& answer_input = child->controls.current_report_frame_details.answer_input;

    if (!answer_input.empty() && !std::ranges::all_of(answer_input, ::isspace))
        return true;

    time_hint_active = std::chrono::steady_clock::now();

    return false;
}

auto plugin::gui::windows::report::frames::current_report::block_report_button_callback() -> void {
    if (!verify_user_input())
        return;

    hint_active = true;
}

auto plugin::gui::windows::report::frames::current_report::send_dialog_action_with_input_check(network::dialog_action action)
    -> void
{
    if (!verify_user_input())
        return;

    child->network.send_dialog_action(action, child->controls.current_report_frame_details.answer_input);
}

auto plugin::gui::windows::report::frames::current_report::get_action_buttons() -> std::deque<action_button> {
    std::deque<action_button> buttons;

    auto it = &child->network;
    auto send_to_a_chat_text = std::format("Отправить в /{} чат", ((server::user::is_on_alogin()) ? 'a' : 'h'));

#define MAKE_BUTTON(LABEL, REQUIRES_ALOGIN, ...) buttons.push_back({ LABEL, std::bind(__VA_ARGS__), REQUIRES_ALOGIN })
    MAKE_BUTTON("Следить", true, &network::send_dialog_action, it, network::dialog_action::spectate, "");
    MAKE_BUTTON(send_to_a_chat_text, false, &network::send_custom_action, it, network::custom_action::send_to_a_chat);
    MAKE_BUTTON("Открыть /stats", true, &network::send_custom_action, it, network::custom_action::open_stats_dialog);
    MAKE_BUTTON("Открыть /pame", true, &network::send_custom_action, it, network::custom_action::open_pame_dialog);
    MAKE_BUTTON("Передать репорт", false, &network::send_dialog_action, it, network::dialog_action::transfer, "");
    MAKE_BUTTON("Поставить метку", false, &network::send_dialog_action, it, network::dialog_action::set_map_point, "");
    MAKE_BUTTON("Удалить репорт", false, &current_report::send_dialog_action_with_input_check, this, network::dialog_action::remove);
    MAKE_BUTTON("Заблокировать репорт", false, &current_report::block_report_button_callback, this);
#undef MAKE_BUTTON

    return buttons;
}

auto plugin::gui::windows::report::frames::current_report::render_title(const ImVec2& item_spacing) const -> void {
    auto& report = child->network.active_report;

    ImGui::PushFont(bold_font, nickname_font_size);
    {
        ImVec2 nickname_size = ImGui::CalcTextSize(report->nickname.c_str());

        ImGui::TextUnformatted(report->nickname.c_str());
        ImGui::PushFont(regular_font, id_font_size);
        {
            ImGui::SameLine(0, item_spacing.x * 2);

            std::string id_text = std::format("ID: {}", report->id);
            ImVec2 id_size = ImGui::CalcTextSize(id_text.c_str());
            float center_y = ImGui::GetCursorPosY() + (nickname_size.y - id_size.y) / 2;

            ImGui::SetCursorPosY(center_y);
            ImGui::TextUnformatted(id_text.c_str());

            std::string left_text = std::format("{} · {}", report->time_sent, get_report_active_time());
            ImVec2 left_text_size = ImGui::CalcTextSize(left_text.c_str());

            ImGui::SameLine(left_group_width - left_text_size.x);
            ImGui::SetCursorPosY(center_y);
            ImGui::TextUnformatted(left_text.c_str());
        }
        ImGui::PopFont();
    }
    ImGui::PopFont();
}

auto plugin::gui::windows::report::frames::current_report::render_insert_buttons(const ImVec2& item_spacing) -> void {
    ImVec2 button_size = { (left_group_width - item_spacing.x * (max_insert_buttons_count_on_line - 1))
        / max_insert_buttons_count_on_line, (ImGui::GetContentRegionAvail().y - item_spacing.y) / 2 };

    auto& insert_buttons = (*configuration)["windows"]["report"]["insert_buttons"];

    for (const auto& [ index, button ] : insert_buttons | std::views::enumerate) {
        if (index > 0 && index != max_insert_buttons_count_on_line)
            ImGui::SameLine();

        std::string name = button["name"];
        std::string truncated = string_utils::truncate_text(name, button_size.x);

        if (!widgets::button(name, "insert_button-" + std::to_string(index), button_size).render())
            continue;

        auto& controls_details = child->controls.current_report_frame_details;
        controls_details.answer_input = button["insert"];
    }
}

auto plugin::gui::windows::report::frames::current_report::render_action_buttons(const ImVec2& item_spacing) -> void {
    auto buttons = get_action_buttons();

    ImVec2 region_avail = ImGui::GetContentRegionAvail();
    ImVec2 button_size = { region_avail.x, (region_avail.y - (item_spacing.y * (buttons.size() - 1))) / buttons.size() };

    ImGui::BeginGroup();
    {
        for (const auto& [ index, button ] : buttons | std::views::enumerate) {
            if (widgets::button(button.label, "action_button-" + std::to_string(index), button_size).render())
                button.callback();

            if (button.requires_alogin)
                widgets::hint("Доступно только администраторам!##action-button-" + std::to_string(index),
                              style::get_current_accent_colors().red)
                    .with_condition([]{ return ImGui::IsItemHovered() && !server::user::is_on_alogin(); })
                    .render();
        
            if (button.label == "Заблокировать репорт")
                widgets::hint("block-report-hint", ImGui::GetColorU32(ImGuiCol_ChildBg))
                    .with_condition([this] { return hint_active; })
                    .with_renderer(std::bind(&current_report::hint_renderer, this))
                    .render();
        }
    }
    ImGui::EndGroup();
}

auto plugin::gui::windows::report::frames::current_report::render_multiline_input_hint(const std::string& hint) const
    -> void
{
    ImDrawList* draw_list = ImGui::GetWindowDrawList();

    ImVec2 start = ImGui::GetItemRectMin();
    ImVec2 input_size = ImGui::GetItemRectSize();
    ImU32 color = ImGui::GetColorU32(ImGuiCol_TextDisabled);

    float y_offset = start.y + (input_size.y - ImGui::CalcTextSize(hint.c_str()).y) / 2.0f;
    std::stringstream stream(hint);

    for (std::string line; std::getline(stream, line);) {
        ImVec2 text_size = ImGui::CalcTextSize(line.c_str());
        ImVec2 center = { start.x + (input_size.x - text_size.x) / 2.0f, y_offset };

        draw_list->AddText(center, color, line.c_str());

        y_offset += text_size.y;
    }
}

auto plugin::gui::windows::report::frames::current_report::render_inputs(const ImVec2& item_spacing) -> void {
    auto& controls_details = child->controls.current_report_frame_details;
    float report_input_height = ImGui::GetContentRegionAvail().y / 2.0f;
    float frame_height = ImGui::GetFrameHeight();

    ImGui::InputTextMultiline("##report", &child->network.active_report->text, { left_group_width, report_input_height },
                              ImGuiInputTextFlags_ReadOnly | ImGuiInputTextFlags_WordWrap);

    float answer_input_height = ImGui::GetContentRegionAvail().y - (frame_height + item_spacing.y) * 2;
    ImVec2 answer_input_size = { left_group_width - frame_height * 1.5f - item_spacing.x, answer_input_height };

    if (ImGui::InputTextMultiline("##answer", &controls_details.answer_input, answer_input_size,
                                  ImGuiInputTextFlags_WordWrap | ImGuiInputTextFlags_EnterReturnsTrue) && verify_user_input())
    {    
        child->network.send_answer(controls_details.answer_input);
    }
    
    if (controls_details.focus_answer_input) {
        ImGui::SetKeyboardFocusHere(-1);
        controls_details.focus_answer_input = false;
    }

    widgets::hint("Поле ввода ответа не должно быть пустым", style::get_current_accent_colors().red)
        .with_condition([this] { return std::chrono::steady_clock::now() - time_hint_active < 5s; })
        .render();   

    if (controls_details.answer_input.empty())
        render_multiline_input_hint("Поле ввода ответа или причины для блокировки\nПримечание: поддерживается отправка до трех строк");

    ImGui::SameLine();
    ImGui::PushFont(icon_font, icon_font_size);
    {
        if (widgets::button(ICON_PAPER_PLANE "##report", { frame_height * 1.5f, answer_input_height })
                .render() && verify_user_input())
        {
            child->network.send_answer(controls_details.answer_input);
        }
    }
    ImGui::PopFont();
}

auto plugin::gui::windows::report::frames::current_report::render() -> void {
    ImVec2 item_spacing = ImGui::GetStyle().ItemSpacing;
    ImVec2 window_padding = ImGui::GetStyle().WindowPadding;

    left_group_width = ImGui::GetWindowWidth() / 1.5f;

    ImGui::BeginGroup();
    {
        render_title(item_spacing);
        render_inputs(item_spacing);
        render_insert_buttons(item_spacing);
    }
    ImGui::EndGroup();
    ImGui::SameLine(0.0f, window_padding.x);
    ImGui::SetCursorPosY(ImGui::GetCursorPosY() - item_spacing.y + window_padding.y);
    render_action_buttons(item_spacing);
}
