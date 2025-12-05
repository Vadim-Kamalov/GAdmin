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
    
    auto window_configuration = (*configuration)["windows"]["report"];
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

auto plugin::gui::windows::report::on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool {
    static constexpr ctll::fixed_string report_information_pattern = R"(Описание репорта:\s+\{FFFFFF\}(.+)\n)";

    if (!dialog || dialog.title != "Обработка репорта" || !current_report.has_value())
        return true;

    dialog_active = true;
    dialog_id = dialog.id;

    std::string dialog_text = dialog.text;

    if (auto matches = types::u8regex::search<report_information_pattern>(dialog_text); matches && current_report->text.empty()) {
        current_report->time_taken = std::chrono::steady_clock::now();
        current_report->text = matches.get_string<1>();

        open_window();
        
        return false;
    }

    if (dialog.style == samp::dialog::style::input) {
        dialog.send_response(samp::dialog::button::right, samp::dialog::list_item_none,
                             string_utils::to_cp1251(*current_response->message));

        close_report();
        
        return false;
    }

    if (dialog_text.contains("Перейти в режим наблюдения за игроком")) {
        dialog.send_response(samp::dialog::button::right, std::to_underlying(current_response->option));
        
        if (current_response->option == dialog_option::return_to_administration)
            close_report();

        return false; 
    }

    if (dialog_text.contains("Заблокировать на")) {
        dialog.send_response(samp::dialog::button::right, current_response->block_time);
        close_report();
    }

    return false;
}

auto plugin::gui::windows::report::on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool {
    static constexpr ctll::fixed_string new_report_pattern = R"(^\| На вас был назначен репорт от игрока (\S+)\[(\d+)\])";
    static constexpr types::zstring_t report_canceled_message = "| Обработка репорта завершена.";

    message.set_continuous_text_callback(wrap_storage, [this](const std::string_view& text, const types::color&) {
        if (text.substr(0, std::char_traits<char>::length(report_canceled_message)) == report_canceled_message) {
            on_report_canceled();
            return;
        }
        
        auto matches = types::u8regex::search<new_report_pattern>(text);

        if (!matches)
            return;

        on_new_report_message(matches.get_string<1>(), std::stoi(matches.get_string<2>()));
    });

    return true;
}

auto plugin::gui::windows::report::on_new_report_message(const std::string& nickname, std::uint16_t id) -> void {
    auto& window_configuration = (*configuration)["windows"]["report"];

    time_received_report = std::chrono::steady_clock::now();
    current_report = { nickname, "", id };

    if (window_configuration["notify"]) {
        std::string title = std::format("Репорт от {}[{}]", nickname, id);
        std::string description = std::format("У вас есть 15 секунд принять. Введите /grep(ort) или нажмите на {}.",
                                              switch_window_hotkey.bind);

        notification::button second_button = { "Закрыть", [](notification& it) { it.remove(); }};
        notification::button first_button = { "Принять", [this](notification& it) {
            open_window_with_dialog();
            it.remove();
        }};

        notification_active = true;

        notify::send(notification(title, description, ICON_USER02)
            .with_buttons(first_button, second_button)
            .with_condition([this] { return notification_active; })
            .with_duration(15s));
    }

    if (!window_configuration["sound_notify"])
        return;

    samp::audio::play_sound(samp::audio::sound_id::bell);
}

auto plugin::gui::windows::report::on_report_canceled() -> void {
    notification_active = false;
    current_report = {};

    if (active)
        close_window();

    auto& window_configuration = (*configuration)["windows"]["report"];

    if (!window_configuration["notify"])
        return;

    notify::send(notification("Обработка репорта завершена",
                              "Игрок был отсоединен от сервера",
                              ICON_CLOSE_M_D));
}

auto plugin::gui::windows::report::open_window() -> void {
    if (reset)
        return;

    time_switched_window = std::chrono::steady_clock::now();
    time_received_report = {};
    active = focus = true;
    notification_active = false;
}

auto plugin::gui::windows::report::open_window_with_dialog() -> void {
    open_window();
    samp::input::send_command("/greport");
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

    notify::send(notification("Напоминание про активный /greport", description, ICON_USER02)
            .with_duration(std::clamp<std::chrono::seconds>(seconds_until_notification, 1s, 5s)));

    time_holding_report = now;
}

auto plugin::gui::windows::report::get_time_active() const -> std::string {
    auto duration = std::chrono::steady_clock::now() - current_report->time_taken;
    auto minutes = std::chrono::duration_cast<std::chrono::minutes>(duration);
    
    duration -= minutes;
    
    auto seconds = std::chrono::duration_cast<std::chrono::seconds>(duration);

    return std::format("{:02}:{:02}", minutes.count(), seconds.count());
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

    auto now = std::chrono::steady_clock::now();

    if (animation::is_time_available(time_received_report) && now - time_received_report >= 15s) {
        time_received_report = {};
        current_report = {};
        return;
    }

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

    child->hotkey_handler->add(switch_window_hotkey);
}
