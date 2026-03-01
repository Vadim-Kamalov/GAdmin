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

#include "plugin/gui/windows/report.h"
#include "plugin/game/game.h"
#include "plugin/gui/animation.h"
#include "plugin/gui/icon.h"
#include "plugin/gui/notify.h"
#include "plugin/gui/style.h"
#include "plugin/gui/widgets/hint.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/gui/animation.h"
#include "plugin/samp/core/audio.h"
#include "plugin/samp/core/dialog.h"
#include "plugin/samp/core/input.h"
#include "plugin/server/user.h"
#include "plugin/string_utils.h"
#include "plugin/types/simple.h"
#include "plugin/plugin.h"
#include "plugin/types/u8regex.h"
#include <misc/cpp/imgui_stdlib.h>
#include <minwindef.h>
#include <chrono>
#include <ranges>

auto plugin::gui::windows::report::get_action_buttons() -> std::array<action_button, 12> {
    std::array<action_button, 12> output;
    std::string id = std::format("##{}", get_id());

    auto& window_configuration = (*configuration)["windows"]["report"];
    ImVec2 padding = ImGui::GetStyle().WindowPadding;
    ImVec2 spacing = ImGui::GetStyle().ItemSpacing;

    float window_width = ImGui::GetWindowWidth();
    float button_height = (ImGui::GetContentRegionAvail().y - answer_button_height) / max_action_buttons_lines - spacing.y;

    ImVec2 corner_button_size = { window_width / max_buttons_per_line - padding.x, button_height }; 
    ImVec2 middle_button_size = { window_width / max_buttons_per_line - spacing.x * 2, button_height };

    output[0] = { widgets::button("Следить" + id, corner_button_size),
                  std::bind(&report::send_response, this, dialog_option::spectate) };

    output[1] = { widgets::button("Удалить" + id, middle_button_size),
                  std::bind(&report::send_input_response, this, dialog_option::remove) };

    output[2] = { widgets::button("Поставить метку" + id, corner_button_size),
                  std::bind(&report::send_response, this, dialog_option::set_map_point) };
    
    output[3] = { widgets::button("Отправить в /a чат" + id, corner_button_size),
                  std::bind(&report::send_chat_action_button, this) };
    
    output[4] = { widgets::button("Заблокировать репорт" + id, middle_button_size),
                  std::bind(&report::block_action_button, this) };

    output[5] = { widgets::button("Передать репорт" + id, corner_button_size),
                  std::bind(&report::send_response, this, dialog_option::return_to_administration) };

    for (int i = 6; i < output.size(); i++) {
        insert_button button = window_configuration["insert_buttons"][i - 6];
        ImVec2 button_size = (i == 7 || i == 10) ? middle_button_size : corner_button_size;

        output[i] = { widgets::button("> " + button.name + id, button_size),
                      [this, button] { answer_input = button.insert; }};
    }

    return output;
}

auto plugin::gui::windows::report::send_chat_action_button() const -> void {
    samp::input::send_command("/a {}[{}]: {}", current_report->nickname,
                              current_report->id, current_report->text);
}

auto plugin::gui::windows::report::block_action_button() -> void {
    if (!can_send_response())
        return;

    ImGui::OpenPopup("block_time_selection");
}

auto plugin::gui::windows::report::on_dialog_response(const samp::out_event<samp::event_id::dialog_response>& id) -> bool {
    if (current_report_type == report_type::waiting)
        current_report_type = static_cast<report_type>(id.list_item_id);

    return true;
}

auto plugin::gui::windows::report::on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool {
    if (!dialog || !server::user::is_on_alogin())
        return true;

    if (current_report_type == report_type::waiting)
        current_report_type = report_type::none;

    if (dialog.title == "Активные репорты")
        return try_handle_active_reports_dialog(dialog);

    if (dialog.title == "Обработка репорта")
        return try_handle_active_report_dialog(dialog);

    return true;
}

auto plugin::gui::windows::report::on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool {
    if (!try_handle_report_searching(message.text))
        return false;

    if (!message.text.contains("Обработка репорта завершена."))
        return true;

    current_report_type = report_type::none;
    time_holding_report = {};
    current_report = {};

    if (active)
        close_window();

    auto& window_configuration = (*configuration)["windows"]["report"];

    if (!window_configuration["notify"])
        return true;

    notify::send(notification("Обработка репорта завершена",
                              "Игрок был отсоединен от сервера",
                              ICON_CLOSE_M_D));

    return true;
}

auto plugin::gui::windows::report::try_handle_active_reports_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool {
    if (dialog.buttons.first == "Принять" && dialog.buttons.second == "Назад") {
        if (!searching_reports)
            return true;

        dialog.send_response(samp::dialog::button::right);
        searching_reports = false;

        return false;
    }

    if (dialog.text.contains("Репорты игровых помощников")) {
        if ((current_report_type == report_type::question || current_report_type == report_type::complaint)
            && (searching_reports || current_report.has_value()))
        {
            dialog.send_response(samp::dialog::button::right, std::to_underlying(current_report_type));
            return false;
        }

        current_report_type = report_type::waiting;

        return true;
    }

    if (!dialog.text.contains("{FFFFFF}Номер") || !searching_reports)
        return true;

    dialog.send_response(samp::dialog::button::right, 0);

    return false;
}

auto plugin::gui::windows::report::try_handle_active_report_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool {
    static constexpr ctll::fixed_string report_information_pattern =
        R"(\{4a86b6\}.* (\d+:\d+:\d+).*\{FFFFFF\}Игрок \(ID\): \{4a86b6\}(.+) \((\d)+\).*Описание репорта:\s+\{FFFFFF\}(.+)\n)";

    dialog_active = true;
    dialog_id = dialog.id;

    if (auto matches = types::u8regex::search<report_information_pattern>(dialog.text); !current_report.has_value() && matches) {
        if (current_report_type == report_type::none)
            current_report_type = report_type::complaint;

        notification_active = false;
        current_report = report_information_t {
            .nickname = matches.get_string<2>(),
            .str_time = matches.get_string<1>(),
            .text = matches.get_string<4>(),
            .id = static_cast<std::uint16_t>(std::stoull(matches.get_string<3>())),
            .time_taken = std::chrono::steady_clock::now()
        };

        open_window();
        
        return false;
    }

    if (dialog.style == samp::dialog::style::input) {
        dialog.send_response(samp::dialog::button::right, samp::dialog::list_item_none,
                             string_utils::to_cp1251(*current_response->message));

        close_report();
        
        return false;
    }

    if (dialog.text.contains("Перейти в режим наблюдения за игроком")) {
        dialog.send_response(samp::dialog::button::right, std::to_underlying(current_response->option));
        
        if (current_response->option == dialog_option::return_to_administration)
            close_report();

        return false; 
    }

    if (dialog.text.contains("Заблокировать на")) {
        dialog.send_response(samp::dialog::button::right, current_response->block_time);
        close_report();
    }

    return false;
}

auto plugin::gui::windows::report::open_window() -> void {
    if (reset)
        return;

    time_switched_window = std::chrono::steady_clock::now();
    active = focus = true;
}

auto plugin::gui::windows::report::open_window_with_dialog() -> void {
    open_window();
    samp::input::send_command("/reports");
}

auto plugin::gui::windows::report::close_window() -> void {
    if (reset)
        return;

    time_switched_window = std::chrono::steady_clock::now();
    closing = true;
    child->disable_cursor();

    if (!dialog_active)
        return;

    samp::dialog::send_response(dialog_id, samp::dialog::button::right);
}

auto plugin::gui::windows::report::close_dialog() -> void {
    samp::dialog::send_response(dialog_id, samp::dialog::button::left);
    dialog_active = false;
    close_window();
}

auto plugin::gui::windows::report::switch_window() -> void {
    if (!server::user::is_on_alogin() || !current_report.has_value())
        return;

    (active) ? close_window() : open_window_with_dialog();
}

auto plugin::gui::windows::report::try_handle_report_searching(const std::string& text) -> bool {
    if ((!searching_reports && !current_report.has_value()) &&
        text.starts_with("[H] Репорт от ") || text.starts_with("[A] Репорт от "))
    {
        auto& window_configuration = (*configuration)["windows"]["report"];

        current_report_type = (text[1] == 'H') ? report_type::question : report_type::complaint;

        if (window_configuration["sound_notify"])
            samp::audio::play_sound(samp::audio::sound_id::bell);

        if (window_configuration["notify"]) {
            notification_active = true;

            std::string description = std::format("Для принятия введите /reports или нажмите на {}.", try_accept_last_report_hotkey.bind);
            notification::button first_button = { "Принять", [this](auto& it) { try_accept_last_report(); it.remove(); }};
            notification::button second_button = { "Закрыть", [](auto& it) { it.remove(); }}; 

            notify::send(notification("Пришел новый репорт!", description, ICON_USER02)
                    .with_buttons(first_button, second_button)
                    .with_condition([this] { return notification_active; })
                    .only_unique());
        }

        return true;
    }

    if (!searching_reports || !text.contains("В данный момент нет активных репортов от игроков."))
        return true;

    notify::send(notification("Не удалось принять репорт", "В данный момент нет активных репортов от игроков.",
                              ICON_USER02));
 
    current_report_type = report_type::none;
    searching_reports = false;

    return false;
}

auto plugin::gui::windows::report::handle_remind_notification() -> void {
    long seconds_until_notification_raw = (*configuration)["windows"]["report"]["remind_active_report_after_seconds"];

    if (seconds_until_notification_raw <= 0)
        return;

    auto now = std::chrono::steady_clock::now();
    auto seconds_until_notification = std::chrono::seconds(seconds_until_notification_raw);

    if (!animation::is_time_available(time_holding_report))
        time_holding_report = now;

    if (now - time_holding_report < seconds_until_notification)
        return;

    std::string description = std::format("Прошло {} секунд с момента открытия окна репорта.",
                                          seconds_until_notification_raw);

    notify::send(notification("Напоминание про активный репорт", description, ICON_USER02)
            .with_duration(std::clamp<std::chrono::seconds>(seconds_until_notification, 1s, 5s)));

    time_holding_report = now;
}

auto plugin::gui::windows::report::get_time_active() const -> std::string {
    auto duration = std::chrono::steady_clock::now() - current_report->time_taken;
    auto minutes = std::chrono::duration_cast<std::chrono::minutes>(duration);
    
    duration -= minutes;
    
    auto seconds = std::chrono::duration_cast<std::chrono::seconds>(duration);

    return std::format("{:02}:{:02} ({})", minutes.count(), seconds.count(), current_report->str_time);
}

auto plugin::gui::windows::report::try_accept_last_report() -> void {
    if (searching_reports || !server::user::is_on_alogin())
        return;

    switch (current_report_type) {
        case report_type::waiting:
            return;
        case report_type::none:
            current_report_type = report_type::complaint;
            break;
        default:
            break;
    }

    if (current_report.has_value()) {
        std::string description = std::format("За вами уже закреплен репорт: для его открытия, нажмите на {}",
                                              switch_window_hotkey.bind);

        notify::send(notification("Не удалось принять репорт", description, ICON_CIRCLE_WARNING));

        return;
    }

    searching_reports = true;
    samp::input::send_command("/reports");
}

auto plugin::gui::windows::report::can_send_response() -> bool {
    if (reset)
        return false;

    if (answer_input.empty()) {
        time_hint_active = std::chrono::steady_clock::now();
        return false;
    }

    return true;
}

auto plugin::gui::windows::report::send_response(const dialog_option& option) -> void {
    current_response = { option };
    close_dialog();
}

auto plugin::gui::windows::report::send_input_response(const dialog_option& option) -> void {
    if (!can_send_response())
        return;

    current_response = { option, answer_input };
    close_dialog();
}

auto plugin::gui::windows::report::close_report() -> void {
    reset = true;
    dialog_active = false;
    current_response = {};
}

auto plugin::gui::windows::report::render() -> void {
    auto& window_configuration = (*configuration)["windows"]["report"];

    if (!window_configuration["use"])
        return;

    if (!active) {
        if (dialog_active)
            handle_remind_notification();

        return;
    }

    time_holding_report = {};
    window_alpha = animation::bring_to(window_alpha, (closing) ? 0 : 255, time_switched_window, animation_duration);
    
    if (!closing && window_alpha != 255 && !child->is_cursor_active())
        child->enable_cursor();

    if (window_alpha == 0 && closing) {
        closing = active = false;
        if (reset) {
            current_report_type = report_type::none;
            current_report = {};
            answer_input.clear();
            reset = false;

            return;
        }
    }

    auto [ size_x, size_y ] = game::get_screen_resolution();

    ImGui::PushStyleVar(ImGuiStyleVar_Alpha, window_alpha / 255.0f);
    ImGui::SetNextWindowPos({ size_x / 2.0f, size_y / 2.0f }, ImGuiCond_FirstUseEver, { 0.5f, 0.5f });
    ImGui::SetNextWindowSizeConstraints({ 600, 300 }, { FLT_MAX, FLT_MAX });
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoTitleBar);
    {
        ImGui::BeginChild("context", { 0, ImGui::GetWindowHeight() / 3 }, ImGuiChildFlags_Borders);
        {
            ImGui::BeginGroup();
            {
                widgets::text(bold_font, bold_font_size, 0, "{}[{}]", current_report->nickname, current_report->id);
                ImGui::PushFont(regular_font, regular_font_size);
                {
                    ImGui::TextWrapped("%s", current_report->text.c_str());
                }
                ImGui::PopFont();
            }
            ImGui::EndGroup();
            ImGui::PushFont(bold_font, bold_font_size);
            {
                std::string time_active = get_time_active();
                ImGui::SameLine(ImGui::GetContentRegionAvail().x - ImGui::CalcTextSize(time_active.c_str()).x);
                ImGui::TextUnformatted(time_active.c_str());
            }
            ImGui::PopFont();
        }
        ImGui::EndChild();
        ImGui::PushFont(regular_font, regular_font_size);
        {
            ImGui::SetNextItemWidth(ImGui::GetContentRegionAvail().x);
           
            if (focus) {
                ImGui::SetKeyboardFocusHere();
                focus = false;
            }

            if (ImGui::InputTextWithHint("##answer", "Поле ввода ответа/причины (Enter - отправить)", &answer_input,
                                         ImGuiInputTextFlags_EnterReturnsTrue) && can_send_response())
            {
                send_input_response(dialog_option::answer);
            }

            widgets::hint("Поле ответа не должно быть пустым", style::get_current_accent_colors().red)
                .with_condition([this] { return std::chrono::steady_clock::now() - time_hint_active < 5s; })
                .render();
            
            for (const auto& [ index, action_button ] : get_action_buttons() | std::views::enumerate) {
                if (action_button.widget.render() && !reset)
                    action_button.callback();

                if ((index + 1) % max_buttons_per_line != 0)
                    ImGui::SameLine();
            }

            if (widgets::button("Ответить##windows::report", { ImGui::GetContentRegionAvail().x, answer_button_height })
                    .render() && can_send_response())
            {
                send_input_response(dialog_option::answer);
            }
        }
        ImGui::PopFont();

        if (ImGui::BeginPopupModal("block_time_selection", nullptr, ImGuiWindowFlags_NoTitleBar)) {
            widgets::text(bold_font, bold_font_size, 0, "Выберите время блокировки");
            ImGui::PushFont(regular_font, regular_font_size);
            {
                float full_width = ImGui::GetContentRegionAvail().x;
               
                for (std::uint8_t index = 0; index < std::size(block_time_options); index++) {
                    if (widgets::button(std::to_string(block_time_options[index]) + " минут##block_time_selection", { full_width, 25 })
                                .render())
                    {
                        current_response = { dialog_option::block, answer_input, index };
                        ImGui::CloseCurrentPopup();
                        close_dialog();
                    }
                }
            
                if (widgets::button("Закрыть##block_time_selection", { full_width, 30 })
                        .render())
                {
                    ImGui::CloseCurrentPopup();
                }
            }
            ImGui::PopFont();
            ImGui::EndPopup();
        }
    }
    ImGui::End();
    ImGui::PopStyleVar();
}

auto plugin::gui::windows::report::on_event(const samp::event_info& event) -> bool {
    if (!(*configuration)["windows"]["report"]["use"])
        return true;

    if (event == samp::event_type::incoming_rpc) {
        if (event == samp::event_id::server_message)
            return on_server_message(event.create<samp::event_id::server_message>());

        if (event == samp::event_id::show_dialog) {
            return on_show_dialog(event.create<samp::event_id::show_dialog>());
        }
    } else if (event == samp::event_type::outgoing_rpc && event == samp::event_id::dialog_response) {
        return on_dialog_response(event.create<samp::event_id::dialog_response, samp::event_type::outgoing_rpc>());
    }

    return true;
}

auto plugin::gui::windows::report::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool {
    if (message == WM_KEYUP && wparam == VK_ESCAPE && active) {
        close_window();
        return false;
    }

    return true;
}

auto plugin::gui::windows::report::create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t {
    return std::make_unique<report>(child);
}

plugin::gui::windows::report::report(types::not_null<gui_initializer*> child)
    : window(child, get_id()),
      bold_font(child->fonts->bold),
      regular_font(child->fonts->regular)
{
    switch_window_hotkey = hotkey("Открыть/закрыть окно репорта", key_bind({ 'K', 0 }, bind_condition::on_alogin))
        .with_callback(std::bind(&report::switch_window, this));

    try_accept_last_report_hotkey = hotkey("Принять последний репорт", key_bind({ 'O', 0 }, bind_condition::on_alogin))
        .with_callback(std::bind(&report::try_accept_last_report, this));

    child->hotkey_handler->add(switch_window_hotkey);
    child->hotkey_handler->add(try_accept_last_report_hotkey);
}
