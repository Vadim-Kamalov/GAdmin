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

#include "plugin/gui/windows/report/network.h"
#include "plugin/gui/windows/report/initializer.h"
#include "plugin/gui/windows/report/frames/user_all_answers.h"
#include "plugin/gui/notify.h"
#include "plugin/gui/icon.h"
#include "plugin/gui/gui.h"
#include "plugin/samp/core/input.h"
#include "plugin/samp/core/audio.h"
#include "plugin/types/u8regex.h"
#include "plugin/common_utils.h"
#include "plugin/plugin.h"
#include <ctre.hpp>
#include <chrono>

auto plugin::gui::windows::report::network::try_accept_last_report() -> void {
    if (searching_reports)
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

    if (active_report.has_value()) {
        std::string description = std::format("За вами уже закреплен репорт: для его открытия, нажмите на {}",
                                              switch_window_hotkey.bind);

        notify::send(notification("Не удалось принять репорт", description, ICON_CIRCLE_WARNING));

        return;
    }

    searching_reports = true;
    samp::input::send_command("/reports");
}

auto plugin::gui::windows::report::network::try_handle_report_searching(const std::string& text) -> bool {
    if ((!searching_reports && !active_report.has_value()) &&
        (text.starts_with("[H] Репорт от ") || text.starts_with("[A] Репорт от ") || text.starts_with("[A] /ask")))
    {
        auto& window_configuration = (*configuration)["windows"]["report"];

        current_report_type = (text[1] == 'H') ? report_type::question : report_type::complaint;

        if (window_configuration["sound_notify"])
            samp::audio::play_sound(samp::audio::sound_id::bell);

        if (window_configuration["notify"]) {
            notification_active = true;

            std::string description = std::format("Для принятия введите /reports или нажмите на {}.", try_accept_last_report_hotkey.bind);
            notification::button first_button("Принять", [this](auto& it) { try_accept_last_report(); it.remove(); });
            notification::button second_button("Закрыть", [](auto& it) { it.remove(); });

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

auto plugin::gui::windows::report::network::try_handle_active_reports_dialog(const samp::event<samp::event_id::show_dialog>& dialog)
    -> bool
{
    if (dialog.buttons.first == "Принять" && dialog.buttons.second == "Назад") {
        if (!searching_reports)
            return true;

        dialog.send_response(samp::dialog::button::right);
        searching_reports = false;

        return false;
    }

    if (dialog.text.contains("Репорты игровых помощников")) {
        if ((current_report_type == report_type::question || current_report_type == report_type::complaint)
            && (searching_reports || active_report.has_value()))
        {
            dialog.send_response(samp::dialog::button::right, std::to_underlying(current_report_type));
            return false;
        }

        current_report_type = report_type::waiting;

        return true;
    }

    if (!dialog.text.contains("{FFFFFF}Номер") || !searching_reports)
        return true;

    dialog.send_response(samp::dialog::button::right, std::ranges::count(dialog.text, '\n') - 2);

    return false;
}

auto plugin::gui::windows::report::network::try_handle_active_report_dialog(const samp::event<samp::event_id::show_dialog>& dialog)
    -> bool
{
    static constexpr ctll::fixed_string report_information_pattern =
        R"(\{4a86b6\}.* (\d+:\d+:\d+).*\{FFFFFF\}Игрок \(ID\): \{4a86b6\}(.+) \((\d+)\).*Описание репорта:\s+\{FFFFFF\}(.+)\n)";

    dialog_active = true;
    dialog_id = dialog.id;

    if (auto matches = types::u8regex::search<report_information_pattern>(dialog.text); !active_report.has_value() && matches) {
        if (current_report_type == report_type::none)
            current_report_type = report_type::complaint;

        notification_active = false;
        active_report = active_report_t {
            .nickname = matches.get_string<2>(),
            .time_sent = matches.get_string<1>(),
            .text = matches.get_string<4>(),
            .id = static_cast<std::uint16_t>(std::stoull(matches.get_string<3>())),
            .time_taken = std::chrono::steady_clock::now()
        };

        open_window();
        
        return false;
    }

    if (dialog.style == samp::dialog::style::input) {
        write_answer_in_dialog(dialog);
        return false;
    }

    if (dialog.text.contains("Перейти в режим наблюдения за игроком")) {
        dialog.send_response(samp::dialog::button::right, std::to_underlying(current_response->action));
        
        if (current_response->action == dialog_action::transfer)
            close_report();

        return false; 
    }

    if (dialog.text.contains("Заблокировать на"))
        dialog.send_response(samp::dialog::button::right, current_response->block_list_item_id);

    return false;
}

auto plugin::gui::windows::report::network::write_answer_in_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> void {
    std::string full_message = current_response->message, line = "";
    std::stringstream stream(full_message);
    
    while (std::getline(stream, line) && line.empty())
        /* nothing */;

    dialog.send_response(samp::dialog::button::right, samp::dialog::list_item_none,
                         string_utils::to_cp1251(line));
    
    if (current_response->action == dialog_action::answer) {
        auto& user_answers = (*configuration)["internal"]["user_answers"];

        user_answers.push_back(user_answer {
            .nickname = active_report->nickname,
            .answer = full_message,
            .time = common_utils::get_current_date(),
            .optional_question = active_report->text
        });

        if (full_message.contains('\n')) {
            std::string prefix = std::format("/ans {} ", active_report->id);
            std::queue<std::string> lines;

            for (int i = 0; i < 2; i++) {
                if (!std::getline(stream, line) || line.empty())
                    continue;

                lines.push(prefix + line);
            }

            multiline_answer = { lines, std::chrono::steady_clock::now() };
        }
    }

    close_report();
}

auto plugin::gui::windows::report::network::on_dialog_response(const samp::out_event<samp::event_id::dialog_response>& id) -> bool {
    if (current_report_type == report_type::waiting)
        current_report_type = static_cast<report_type>(id.list_item_id);

    return true;
}

auto plugin::gui::windows::report::network::on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool {
    if (!dialog)
        return true;

    if (current_report_type == report_type::waiting)
        current_report_type = report_type::none;

    if (dialog.title == "Активные репорты")
        return try_handle_active_reports_dialog(dialog);

    if (dialog.title == "Обработка репорта")
        return try_handle_active_report_dialog(dialog);

    return true;
}

auto plugin::gui::windows::report::network::on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool {
    if (!try_handle_report_searching(message.text))
        return false;

    if (!message.text.contains("Обработка репорта завершена."))
        return true;

    current_report_type = report_type::none;
    active_report = {};
    time_holding_report = {};

    if (window_active)
        close_window();

    auto& window_configuration = (*configuration)["windows"]["report"];

    if (!window_configuration["notify"])
        return true;

    notify::send(notification("Обработка репорта завершена",
                              "Игрок был отсоединен от сервера",
                              ICON_CLOSE_M_D));

    return true;
}

auto plugin::gui::windows::report::network::open_window() -> void {
    if (resetting_report)
        return;

    time_switched_window = std::chrono::steady_clock::now();
    window_active = true;

    child->controls.current_report_frame_details.focus_answer_input = true;
}

auto plugin::gui::windows::report::network::open_window_with_dialog() -> void {
    open_window();
    samp::input::send_command("/reports");
}

auto plugin::gui::windows::report::network::close_window() -> void {
    if (resetting_report)
        return;

    time_switched_window = std::chrono::steady_clock::now();
    closing_window = true;

    child->child->disable_cursor();

    if (!dialog_active)
        return;

    samp::dialog::send_response(dialog_id, samp::dialog::button::right);
}

auto plugin::gui::windows::report::network::switch_window() -> void {
    if (!active_report.has_value())
        return;

    (window_active) ? close_window() : open_window_with_dialog();
}

auto plugin::gui::windows::report::network::close_dialog() -> void {
    samp::dialog::send_response(dialog_id, samp::dialog::button::left);
    dialog_active = false;
    close_window();
}

auto plugin::gui::windows::report::network::close_report() -> void {
    if (!window_active) {
        current_report_type = report_type::none;
        resetting_report = dialog_active = false;

        active_report = {};
        current_response = {};

        child->controls.set_answer_input_text("", false);
        
        return;
    }

    resetting_report = true;
    dialog_active = false;
    current_response = {};
}

auto plugin::gui::windows::report::network::handle_multiline_answer() -> void {
    if (!multiline_answer.has_value())
        return;

    if (multiline_answer->lines.empty()) {
        multiline_answer = {};
        return;
    }

    auto now = std::chrono::steady_clock::now();
    auto delay = std::chrono::milliseconds(SERVER_COMMAND_DELAY_MS);

    if (multiline_answer->time + delay >= now)
        return;

    samp::input::send_command("{}", multiline_answer->lines.front());
    
    multiline_answer->time = now;
    multiline_answer->lines.pop();
}

auto plugin::gui::windows::report::network::handle_remind_notification() -> void {
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

auto plugin::gui::windows::report::network::send_dialog_action(dialog_action action, const std::string& optional_text)
    -> void
{
    current_response = dialog_response { action, optional_text };
    close_dialog();
}

auto plugin::gui::windows::report::network::send_custom_action(custom_action action) -> void {
    std::string optional_dialog_open_command = "";

    switch (action) {
        case custom_action::send_to_a_chat:
            samp::input::send_command("/a {}[{}]: {}", active_report->nickname,
                                      active_report->id, active_report->text);
            return;
        case custom_action::open_stats_dialog:
            optional_dialog_open_command = "stats";
            break;
        case custom_action::open_pame_dialog:
            optional_dialog_open_command = "pame";
            break;
    }

    samp::input::send_command("/{} {}", optional_dialog_open_command, active_report->id);
    close_window();
}

auto plugin::gui::windows::report::network::send_answer(const std::string& answer) -> void {
    current_response = dialog_response { dialog_action::answer, answer };
    close_dialog();
}

auto plugin::gui::windows::report::network::block_report(const std::string& reason, std::uint8_t block_list_item_id) -> void {
    current_response = dialog_response { dialog_action::block, reason, block_list_item_id };
    close_dialog();
}

auto plugin::gui::windows::report::network::can_save_answer() const -> bool {
    return !active_report.has_value() && !multiline_answer.has_value();
}

auto plugin::gui::windows::report::network::can_render_window() -> bool {
    static constexpr std::chrono::milliseconds animation_duration = 500ms;

    handle_multiline_answer();

    if (!(*configuration)["windows"]["report"]["use"])
        return false;

    if (!window_active) {
        if (dialog_active)
            handle_remind_notification();
    
        return false;
    }

    std::uint8_t& window_alpha = child->controls.initializer_details.window_alpha;

    window_alpha = animation::bring_to(window_alpha, (closing_window) ? 0 : 255,
                                       time_switched_window, animation_duration);
    
    time_holding_report = {};

    if (window_alpha == 0 && closing_window) {
        closing_window = window_active = false;

        if (resetting_report) {
            current_report_type = report_type::none;
            active_report = {};
            resetting_report = false;
        
            child->controls.set_answer_input_text("", false);
        }
   
        return false;
    }

    if (!closing_window && window_alpha != 255 && !child->child->is_cursor_active())
        child->child->enable_cursor();

    return true;
}

auto plugin::gui::windows::report::network::on_event(const samp::event_info& event) -> bool {
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

auto plugin::gui::windows::report::network::on_event(unsigned int message, WPARAM wparam, LPARAM) -> bool {
    if (message == WM_KEYUP && wparam == VK_ESCAPE && window_active) {
        close_window();
        return false;
    }

    return true;
}

plugin::gui::windows::report::network::network(types::not_null<initializer*> child)
    : child(child)
{
    switch_window_hotkey = hotkey("Открыть/закрыть окно репорта", key_bind({ 'K', 0 }, bind_condition::on_alogin))
        .with_callback(std::bind(&network::switch_window, this));

    try_accept_last_report_hotkey = hotkey("Принять последний репорт", key_bind({ 'O', 0 }, bind_condition::on_alogin))
        .with_callback(std::bind(&network::try_accept_last_report, this));

    child->child->hotkey_handler->add(switch_window_hotkey);
    child->child->hotkey_handler->add(try_accept_last_report_hotkey);
}
