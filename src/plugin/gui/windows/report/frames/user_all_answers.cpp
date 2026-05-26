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

#include "plugin/gui/windows/report/frames/user_all_answers.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/samp/core/input.h"
#include "plugin/samp/core/user.h"
#include "plugin/types/u8regex.h"
#include "plugin/string_utils.h"
#include "plugin/common_utils.h"
#include "plugin/plugin.h"
#include "plugin/server/user.h"
#include <misc/cpp/imgui_stdlib.h>
#include <ctre.hpp>

auto plugin::gui::windows::report::frames::user_all_answers::on_server_message(const samp::event<samp::event_id::server_message>& message)
    -> bool
{
    static constexpr ctll::fixed_string answer_request_pattern = R"(\[[AH]\] .+\[(\d+)\] ответил (.+)\[\d+\]: (.+))";

    auto matches = types::u8regex::match<answer_request_pattern>(message.text);

    if (!matches)
        return true;

    std::uint16_t from_id = std::stoull(matches.get_string<1>());

    if (from_id != samp::user::get_id())
        return true;

    auto& user_answers = (*configuration)["internal"]["user_answers"];
    std::string to_nickname = matches.get_string<2>();

    if (!child->network.can_save_answer())
        return true;

    user_answers.push_back(user_answer {
        .nickname = to_nickname,
        .answer = matches.get_string<3>(),
        .time = common_utils::get_current_date()
    });
 
    return true;
}

auto plugin::gui::windows::report::frames::user_all_answers::send_selected_user_answer_to_chat() const -> void {
    char command_name = (server::user::is_on_alogin()) ? 'a' : 'h';
    std::string answer = selected_user_answer->answer;

    if (answer.contains('\n')) {
        std::stringstream stream(answer);
        std::getline(stream, answer);
    }

    samp::input::send_command("/{} [{}] Ответ к {}: {}", command_name, selected_user_answer->time,
                              selected_user_answer->nickname, answer);
}

auto plugin::gui::windows::report::frames::user_all_answers::render_user_answers() -> void {
    std::vector<user_answer> items = (*configuration)["internal"]["user_answers"];
    std::vector<user_answer>* items_ptr = &items;
    std::vector<user_answer> filtered_items;

    if (!search.empty()) {
        for (const auto& item : items) {
            std::string prefix = (item.optional_question.empty()) ? "ANS" : "REPORT";

            if (!search.contains("[{}] {}: {}", prefix, item.nickname, item.answer))
                continue;

            filtered_items.push_back(item);
        }

        items_ptr = &filtered_items;
    }

    ImGuiListClipper clipper;
    clipper.Begin(items_ptr->size());

    while (clipper.Step()) {
        for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
            ImVec2 button_size = { ImGui::GetContentRegionAvail().x, ImGui::GetFrameHeight() };
            auto& item = (*items_ptr)[i];

            std::string answer = item.answer;

            if (answer.contains('\n')) {
                std::stringstream stream(answer);
                std::getline(stream, answer);
            }

            std::string prefix = (item.optional_question.empty()) ? "ANS" : "REPORT";
            std::string button_id = std::format("user_answer-{}", i);
            std::string text_original = std::format("[{}] Ответ к {}: {}", prefix, item.nickname, answer);
            std::string text_truncated = string_utils::truncate_text(text_original, button_size.x);

            if (widgets::button(text_truncated, button_id, button_size).render() && switch_info.get_alpha() == 1.0f) {
                switch_info.handle_transition(item);
            }
        }
    }
}

auto plugin::gui::windows::report::frames::user_all_answers::render_selected_user_answer_hint() const -> void {
    static constexpr types::zstring_t text = "Выберите ответ для просмотра";

    ImVec2 text_size = ImGui::CalcTextSize(text);
    ImVec2 window_size = ImGui::GetWindowSize();

    ImGui::SetCursorPos({ (window_size.x - text_size.x) / 2.0f, (window_size.y - text_size.y) / 2.0f });
    ImGui::TextDisabled(text);
}

auto plugin::gui::windows::report::frames::user_all_answers::render_inputs(const ImVec2& input_size) -> void {
    auto flags = ImGuiInputTextFlags_ReadOnly | ImGuiInputTextFlags_WordWrap;
    std::string question = selected_user_answer->optional_question;
    std::string answer = selected_user_answer->answer;
    
    ImGui::InputTextMultiline("##question", &question, input_size, flags);

    if (question.empty()) {
        static constexpr types::zstring_t text = "Репорт от игрока отсутствует";

        ImVec2 text_size = ImGui::CalcTextSize(text);
        ImVec2 start = ImGui::GetItemRectMin();
        ImVec2 center = { start.x + (input_size.x - text_size.x) / 2.0f,
                          start.y + (input_size.y - text_size.y) / 2.0f };

        ImGui::GetWindowDrawList()->AddText(center, ImGui::GetColorU32(ImGuiCol_TextDisabled), text);
    }

    ImGui::InputTextMultiline("##answer", &answer, input_size, flags);
}

auto plugin::gui::windows::report::frames::user_all_answers::render_selected_user_answer(const ImVec2& item_spacing)
    -> void
{
    ImGui::PushFont(bold_font);
    {
        std::string nickname = selected_user_answer->nickname;
        std::string time = selected_user_answer->time;

        ImGui::TextUnformatted(selected_user_answer->nickname.c_str());
        ImGui::SameLine(ImGui::GetContentRegionAvail().x - ImGui::CalcTextSize(time.c_str()).x);
        ImGui::TextUnformatted(time.c_str());
    }
    ImGui::PopFont();

    ImVec2 region_avail = ImGui::GetContentRegionAvail();
    ImVec2 button_size = { region_avail.x, ImGui::GetFrameHeight() };
    ImVec2 input_size = { region_avail.x, (region_avail.y - button_size.y * 2 - item_spacing.y * 3) / 2.0f };

    render_inputs(input_size);

    std::string id = "frames::user_answers";
    auto send_chat_button_text = std::format("Отправить в /{}##{}", ((server::user::is_on_alogin()) ? 'a' : 'h'), id);
    auto insert_in_input_button_text = std::format("Вставить в поле ввода##{}", id);

    if (widgets::button(send_chat_button_text, button_size).render())
        send_selected_user_answer_to_chat();
    
    if (widgets::button(insert_in_input_button_text, button_size).render()) {
        child->controls.set_answer_input_text(selected_user_answer->answer, true);
        child->controls.go_to_frame(frame::current_report);
    }
}

auto plugin::gui::windows::report::frames::user_all_answers::is_enabled() const -> bool {
    return (*configuration)["windows"]["report"]["enable_user_all_answers_frame"];
}

auto plugin::gui::windows::report::frames::user_all_answers::render() -> void {
    search.render(ImGui::GetContentRegionAvail().x, "Поиск");

    ImVec2 region_avail = ImGui::GetContentRegionAvail();
    ImVec2 item_spacing = ImGui::GetStyle().ItemSpacing;
    ImVec2 child_size = { (region_avail.x - item_spacing.x) / 2.0f, region_avail.y };

    ImGui::BeginChild("##user_answers", child_size, ImGuiChildFlags_AlwaysUseWindowPadding);
    {
        float frame_height = ImGui::GetFrameHeight();
        ImVec2 region_avail = ImGui::GetContentRegionAvail();
        ImVec2 content_size = { child_size.x, region_avail.y - frame_height - item_spacing.y };

        ImGui::SetCursorPos({ 0, 0 });
        ImGui::BeginChild("##content", content_size, ImGuiChildFlags_AlwaysUseWindowPadding);
        {
            render_user_answers();
        }
        ImGui::EndChild();
    
        if (widgets::button("Очистить##frames::user_all_answers", { region_avail.x, frame_height }).render()) {
            (*configuration)["internal"]["user_answers"].clear();
            switch_info.handle_transition({});
        }
    }
    ImGui::EndChild();
    ImGui::SameLine();
    ImGui::BeginChild("##selected_user_answer", child_size, ImGuiChildFlags_AlwaysUseWindowPadding);
    {
        switch_info.handle_animation();

        ImGui::PushStyleVar(ImGuiStyleVar_Alpha, switch_info.get_alpha() * ImGui::GetStyle().Alpha);
        {
            if (selected_user_answer.has_value())
                render_selected_user_answer(item_spacing);
            else
                render_selected_user_answer_hint();
        }
        ImGui::PopStyleVar();
    }
    ImGui::EndChild();
}

auto plugin::gui::windows::report::frames::user_all_answers::on_event(const samp::event_info& event) -> bool {
    if (event == samp::event_id::server_message && event == samp::event_type::incoming_rpc)
        return on_server_message(event.create<samp::event_id::server_message>());

    return true;
}
