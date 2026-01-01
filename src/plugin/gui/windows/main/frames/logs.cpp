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

#include "plugin/gui/windows/main/frames/logs.h"
#include "plugin/gui/notify.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/gui/gui.h"
#include "plugin/types/u8regex.h"
#include "plugin/samp/core/player_pool.h"
#include <ctre.hpp>
#include <ranges>

std::map<plugin::gui::windows::main::frames::logs::log_type_t, plugin::gui::windows::main::frames::logs::log_group>
plugin::gui::windows::main::frames::logs::log_groups = {
    { log_type_t::administration_chat, { "Чат администрации", log_group::conditions_t {
        .start = { "[A] " },
        .colors = { 0xFF00C281 },
        .callback = [](const std::string& text, const types::color& color) -> bool {
            static constexpr ctll::fixed_string pattern = R"(^\[A\d\] \S+\[\d+\]: )";
            return color == 0xFF00C281 && (text.starts_with("[A] ") || !!ctre::search<pattern>(text));
        }
    }}},
    
    { log_type_t::reports, { "Репорты и ответы", log_group::conditions_t {
        .callback = [](const std::string& text, const types::color& color) -> bool {
            return text.starts_with("[A] Жалоба от ") || text.starts_with("[A] Вопрос от ")
                || (text.starts_with("[A]" ) && color == 0xAA4599FF);
        }
    }}},

    { log_type_t::actions, { "Все действия", log_group::conditions_t {
        .start = { "[A] ", "[GBUY] " },
        .colors = { 0xAAAFAFAF, 0xAA32CD9A, 0xAA00FFFF }
    }}},

    { log_type_t::puhishments, { "Наказания", log_group::conditions_t {
        .start = { "Администратор " },
        .colors = { 0xAA4763FF }
    }}},

    { log_type_t::ic_chat, { "IC чат", log_group::conditions_t {
        .callback = [](const std::string& text, const types::color& color) -> bool {
            static constexpr ctll::fixed_string pattern = R"(^(\w+(?: \w+)*) (?:.+?) (говорит|шепчет|кричит):)";
            return color == 0xFF8054E7 || !!types::u8regex::search<pattern>(text);
        }
    }}},

    { log_type_t::ooc_chat, { "OOC чат", log_group::conditions_t {
        .callback = [](const std::string& text, const types::color& color) -> bool {
            static constexpr ctll::fixed_string pattern = R"(\(\( \w+ .+\[\d+\]: .* \)\))";
            return !!ctre::match<pattern>(text);
        }
    }}},

    { log_type_t::kills, { "Убийства" }},
    { log_type_t::connections_disconnections, { "Входы/выходы" }},
    { log_type_t::other, { "Прочее" }}
}; // std::map<plugin::gui::windows::main::frames::logs::log_type_t, plugin::gui::windows::main::frames::logs::log_group>

auto plugin::gui::windows::main::frames::logs::on_server_connect(const samp::event<samp::event_id::server_connect>& event)
    -> bool
{
    log_groups[log_type_t::connections_disconnections].messages.emplace_back(std::format("{}[{}] подключился к серверу.",
                                                                                         event.nickname, event.id));

    return true;
}

auto plugin::gui::windows::main::frames::logs::on_server_quit(const samp::event<samp::event_id::server_quit>& event)
    -> bool
{
    auto nickname = samp::player_pool::get_nickname(event.id);

    if (!nickname)
        return true;

    std::string text = std::format("{}[{}] покинул сервер.", *nickname, event.id); 

#define FINISH_CASE(TEXT) text.append(TEXT); break 
    switch (event.reason) {
        case 0: FINISH_CASE(" Причина: вылет из игры или таймаут.");
        case 1: FINISH_CASE(" Причина: /q.");
        case 2: FINISH_CASE(" Причина: отключен или заблокирован.");
        default: break;
    }
#undef FINISH_CASE

    log_groups[log_type_t::connections_disconnections].messages.emplace_back(text);

    return true;
}

auto plugin::gui::windows::main::frames::logs::on_set_player_name(const samp::event<samp::event_id::set_player_name>& event)
    -> bool
{
    auto source_nickname = samp::player_pool::get_nickname(event.id);

    if (!source_nickname)
        return true;

    log_groups[log_type_t::connections_disconnections].messages.emplace_back(
            std::format("{}[{}] сменил никнейм на {}.", *source_nickname, event.id, event.nickname));

    return true;
}

auto plugin::gui::windows::main::frames::logs::on_server_message(const samp::event<samp::event_id::server_message>& message)
    -> bool
{
    message.set_continuous_text_callback(wrap_storage, [this](const std::string_view& text_view, const types::color& color) {
        std::string text(text_view);

        for (auto& [ _, group ] : log_groups) {
            if (!group.conditions.has_value())
                continue;

            if (group.conditions->callback.has_value()) {
                if ((*group.conditions->callback)(text, color)) {
                    group.messages.emplace_back(text);
                    return;
                }

                continue;
            }

            bool text_matches = group.conditions->start.empty() ||
                std::ranges::any_of(group.conditions->start, [&text](const std::string& prefix) {
                    return text.starts_with(prefix);
                });

            bool color_matches = group.conditions->colors.empty() ||
                std::ranges::any_of(group.conditions->colors, [&color](const types::color& it) {
                    return color == it;
                });

            if (text_matches && color_matches) {
                group.messages.emplace_back(text);
                return;
            }
        }

        log_groups[log_type_t::other].messages.emplace_back(text);
    });

    return true;
}

auto plugin::gui::windows::main::frames::logs::on_death_notification(const samp::event<samp::event_id::player_death_notification>& notification) const
    -> bool
{
    log_groups[log_type_t::kills].messages.emplace_back(notification.to_string());
    return true;
}

auto plugin::gui::windows::main::frames::logs::get_filtered_messages(const std::deque<log_group::message>& messages) const
    -> std::deque<log_group::message>
{
    return messages | std::views::filter([this](const log_group::message& message) {
        return search.contains("{} {}", message.timestamp, message.text);
    }) | std::ranges::to<std::deque<log_group::message>>();
}

auto plugin::gui::windows::main::frames::logs::handle_message_controls(const std::string& text_to_copy) const -> void {
    if (ImGui::IsItemHovered()) {
        ImVec2 end = ImGui::GetItemRectMax();
        ImVec2 start = { ImGui::GetItemRectMin().x, end.y };
        ImGui::GetWindowDrawList()->AddLine(start, end, ImGui::GetColorU32(ImGuiCol_Text), 2);
    }

    if (!ImGui::IsItemClicked())
        return;

    ImGui::SetClipboardText(text_to_copy.c_str());
    gui::notify::send(gui::notification("Текст скопирован", "Лог успешно скопирован!", ICON_COPY));
}

auto plugin::gui::windows::main::frames::logs::frame_renderer(std::string& label, std::any& payload) -> void {
    gui::widgets::text(bold_font, title_font_size, 0, "{}", label);

    log_group& group = log_groups[std::any_cast<log_type_t>(payload)];
    float region_avail_x = ImGui::GetContentRegionAvail().x;

    ImGui::PushFont(regular_font, common_font_size);
    {
        search.render(region_avail_x, "Поиск");
    
        ImGui::BeginChild("scrollable_area", { region_avail_x, ImGui::GetContentRegionAvail().y - clear_button_height
                - ImGui::GetStyle().ItemSpacing.y }, ImGuiChildFlags_AlwaysUseWindowPadding, child->window_flags);
        {
            std::deque<log_group::message> filtered_messages = get_filtered_messages(group.messages);
            ImGuiListClipper clipper;

            clipper.Begin(filtered_messages.size());

            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    log_group::message& message = filtered_messages[i];

                    ImGui::BeginGroup();
                    {
                        gui::widgets::text(bold_font, common_font_size, 0, "{}", message.timestamp);
                        ImGui::SameLine();
                        ImGui::TextWrapped("%s", message.text.c_str());
                    }
                    ImGui::EndGroup();
                    handle_message_controls(message.text);
                }
            }
        }
        ImGui::EndChild();

        if (gui::widgets::button("Очистить##frames::logs::clear", { region_avail_x, clear_button_height }).render())
            group.messages.clear();
    }
    ImGui::PopFont();
}

auto plugin::gui::windows::main::frames::logs::render() -> void {
    submenu.render_menu(child);
    ImGui::SameLine();
    submenu.render_current_frame(child);
}

auto plugin::gui::windows::main::frames::logs::on_event(const samp::event_info& event) -> bool {
    if (event == samp::event_type::incoming_rpc) {
        if (event == samp::event_id::server_message)
            return on_server_message(event.create<samp::event_id::server_message>());
        else if (event == samp::event_id::player_death_notification)
            return on_death_notification(event.create<samp::event_id::player_death_notification>());
        else if (event == samp::event_id::server_connect)
            return on_server_connect(event.create<samp::event_id::server_connect>());
        else if (event == samp::event_id::server_quit)
            return on_server_quit(event.create<samp::event_id::server_quit>());
        else if (event == samp::event_id::set_player_name) {
            return on_set_player_name(event.create<samp::event_id::set_player_name>());
        }
    }

    return true;
}

plugin::gui::windows::main::frames::logs::logs(types::not_null<initializer*> child)
    : child(child),
      bold_font(child->child->fonts->bold),
      regular_font(child->child->fonts->regular)
{
    using namespace std::placeholders;

    submenu.set_frame_renderer(std::bind(&logs::frame_renderer, this, _1, _2));

    for (const auto& [ type, group ] : log_groups)
        submenu.add_entry(group.title, std::make_any<log_type_t>(type));
}
