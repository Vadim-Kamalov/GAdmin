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

#include "plugin/gui/windows/report/frames/previous_answers.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/types/u8regex.h"
#include "plugin/plugin.h"
#include <misc/cpp/imgui_stdlib.h>
#include <ctre.hpp>
#include <ranges>
#include <map>

auto plugin::gui::windows::report::frames::previous_answers::on_server_message(const samp::event<samp::event_id::server_message>& message)
    -> bool
{
    static constexpr ctll::fixed_string answer_request_pattern = R"(\[[AH]\] (.+)\[\d+\] ответил (.+)\[\d+\]: (.+))";

    if (auto matches = types::u8regex::match<answer_request_pattern>(message.text))
        answers.push_back({
            .from = matches.get_string<1>(),
            .to = matches.get_string<2>(),
            .text = matches.get_string<3>(),
            .time = std::chrono::system_clock::now()
        });

    return true;
}

auto plugin::gui::windows::report::frames::previous_answers::get_selected_item_time() const -> std::string {
    auto time = std::chrono::system_clock::to_time_t(selected_item->time);
    auto tm = *std::localtime(&time);
    return std::format("{:02}:{:02}:{:02}", tm.tm_hour, tm.tm_min, tm.tm_sec);
}

auto plugin::gui::windows::report::frames::previous_answers::get_answers_to_sender() const -> std::vector<group_item> {
    return answers | std::views::filter([this](const auto& item) {
        return child->network.active_report->nickname == item.to;
    }) | std::ranges::to<std::vector>();
}

auto plugin::gui::windows::report::frames::previous_answers::render_group_items(const std::string_view& id,
                                                                                const std::vector<group_item>& group_items)
    -> void
{
    std::vector<group_item>* items = &const_cast<std::vector<group_item>&>(group_items);
    std::vector<group_item> filtered_items;

    if (!search.empty()) {
        for (const auto& item : group_items) {
            if (!search.contains("{} ответил {}: {}", item.from, item.to, item.text))
                continue;

            filtered_items.push_back(item);
        }

        items = &filtered_items;
    }

    ImGuiListClipper clipper;
    clipper.Begin(items->size());

    while (clipper.Step()) {
        for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
            auto& item = (*items)[i];
            
            ImVec2 button_size = { ImGui::GetContentRegionAvail().x, ImGui::GetFrameHeight() };
            std::string button_id = std::format("{}-group_item-{}", id, i);
            std::string full_text = std::format("{} ответил {}: {}", item.from, item.to, item.text);
            std::string truncated = string_utils::truncate_text(full_text, button_size.x);

            if (widgets::button(truncated, button_id, button_size).render() && switch_info.get_alpha() == 1.0f) {
                switch_info.handle_transition(item);
            }
        }
    }
}

auto plugin::gui::windows::report::frames::previous_answers::render_selected_item_info_hint() const -> void {
    static constexpr types::zstring_t text = "Выберите ответ для просмотра";

    ImVec2 text_size = ImGui::CalcTextSize(text);
    ImVec2 window_size = ImGui::GetWindowSize();

    ImGui::SetCursorPos({ (window_size.x - text_size.x) / 2.0f, (window_size.y - text_size.y) / 2.0f });
    ImGui::TextDisabled(text);
}

auto plugin::gui::windows::report::frames::previous_answers::render_selected_item_info_details()
    -> void
{
    std::vector<std::pair<std::string, std::string>> entries = {
        { "Отправитель:", selected_item->from },
        { "Игрок:", selected_item->to },
        { "Время:", get_selected_item_time() }
    }; // std::vector<std::pair<std::string, std::string>> entries

    for (const auto& [ left, right ] : entries) {
        if (left == "Время:")
            ImGui::SameLine();

        ImGui::BeginGroup();
        {
            ImGui::PushFont(bold_font);
            {
                ImGui::TextUnformatted(left.c_str());
            }
            ImGui::PopFont();
            ImGui::SameLine();
            ImGui::PushFont(regular_font);
            {
                ImGui::TextUnformatted(right.c_str());
            }
            ImGui::PopFont();
        }
        ImGui::EndGroup();
    }

    std::string selected_item_text(selected_item->text);
    
    ImGui::SetNextItemWidth(ImGui::GetContentRegionAvail().x);
    ImGui::InputText("##selected_item_text", &selected_item_text, ImGuiInputTextFlags_ReadOnly);

    if (!widgets::button("Вставить текст в поле ввода", ImGui::GetContentRegionAvail()).render())
        return;

    child->controls.set_answer_input_text(selected_item_text, true);
    child->controls.go_to_frame(frame::current_report);
}

auto plugin::gui::windows::report::frames::previous_answers::render_selected_item_info(const ImVec2& group_size)
    -> void
{
    switch_info.handle_animation();
    ImGui::BeginChild("##selected_item_info", group_size, ImGuiChildFlags_AlwaysUseWindowPadding);
    {
        ImGui::PushStyleVar(ImGuiStyleVar_Alpha, switch_info.get_alpha() * ImGui::GetStyle().Alpha);
        {
            if (selected_item.has_value())
                render_selected_item_info_details();
            else
                render_selected_item_info_hint();
        }
        ImGui::PopStyleVar();
    }
    ImGui::EndChild();
}

auto plugin::gui::windows::report::frames::previous_answers::is_enabled() const -> bool {
    return (*configuration)["windows"]["report"]["enable_previous_answers_frame"];
}

auto plugin::gui::windows::report::frames::previous_answers::render() -> void {
    search.render(ImGui::GetContentRegionAvail().x, "Поиск");

    ImVec2 region_avail = ImGui::GetContentRegionAvail();
    ImVec2 item_spacing = ImGui::GetStyle().ItemSpacing;

    float frame_height = ImGui::GetFrameHeight();
    float group_width = (region_avail.x - item_spacing.y) / 2.0f;

    ImGui::BeginChild("##session_answers", { group_width, region_avail.y }, ImGuiChildFlags_AlwaysUseWindowPadding);
    {
        ImGui::PushFont(bold_font);
        {
            ImGui::TextUnformatted("Все ответы за сессию");
        }
        ImGui::PopFont();
        render_group_items("session_answers", answers);
    }
    ImGui::EndChild();
    ImGui::SameLine();
    ImGui::BeginGroup();
    {
        ImVec2 first_group_size = { group_width, (region_avail.y + frame_height - item_spacing.y) / 2.0f };
        ImGui::BeginChild("##answers_to_sender", first_group_size, ImGuiChildFlags_AlwaysUseWindowPadding);
        {
            ImGui::PushFont(bold_font);
            {
                ImGui::TextUnformatted("Ответы к отправителю репорта");
            }
            ImGui::PopFont();
            render_group_items("answers_to_sender", get_answers_to_sender());
        }
        ImGui::EndChild();
        render_selected_item_info(ImGui::GetContentRegionAvail());
    }
    ImGui::EndGroup();
}

auto plugin::gui::windows::report::frames::previous_answers::on_event(const samp::event_info& event) -> bool {
    if (event == samp::event_id::server_message && event == samp::event_type::incoming_rpc)
        return on_server_message(event.create<samp::event_id::server_message>());

    return true;
}
