#include "plugin/gui/windows/report.h"
#include "plugin/gui/animation.h"
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
#include "plugin/log.h"
#include <chrono>
#include <minwindef.h>
#include <misc/cpp/imgui_stdlib.h>
#include <ranges>
#include <regex>

std::array<plugin::gui::windows::report::action_button, 12>
plugin::gui::windows::report::get_action_buttons() {
    static constexpr std::array<std::chrono::milliseconds, 3> close_button_duration = { 200ms, 0ms, 0ms };
    
    std::array<action_button, 12> output;
    std::string id = std::format("##{}", get_id());
    
    auto window_configuration = (*configuration)["windows"]["report"];
    ImVec2 padding = ImGui::GetStyle().WindowPadding;
    ImVec2 spacing = ImGui::GetStyle().ItemSpacing;

    float window_width = ImGui::GetWindowWidth();
    float button_height = (ImGui::GetContentRegionAvail().y - answer_button_height) / max_action_buttons_lines - spacing.y;

    ImVec2 corner_button_size = { window_width / max_buttons_per_line - padding.x, button_height }; 
    ImVec2 middle_button_size = { window_width / max_buttons_per_line - spacing.x * 2, button_height };

    output[0] = { widgets::button("Следить" + id, corner_button_size).with_durations(close_button_duration),
                  std::bind(&report::send_response, this, dialog_option::spectate) };

    output[1] = { widgets::button("Удалить" + id, middle_button_size).with_durations(close_button_duration),
                  std::bind(&report::send_input_response, this, dialog_option::remove) };

    output[2] = { widgets::button("Поставить метку" + id, corner_button_size).with_durations(close_button_duration),
                  std::bind(&report::send_response, this, dialog_option::set_map_point) };
    
    output[3] = { widgets::button("Отправить в /a чат" + id, corner_button_size),
                  std::bind(&report::send_chat_action_button, this) };
    
    output[4] = { widgets::button("Заблокировать репорт" + id, middle_button_size).with_durations(close_button_duration),
                  std::bind(&report::block_action_button, this) };

    output[5] = { widgets::button("Передать репорт" + id, corner_button_size).with_durations(close_button_duration),
                  std::bind(&report::send_response, this, dialog_option::return_to_administration) };

    for (int i = 6; i < output.size(); i++) {
        insert_button button = window_configuration["insert_buttons"][i - 6];
        ImVec2 button_size = (i == 7 || i == 10) ? middle_button_size : corner_button_size;

        output[i] = { widgets::button("> " + button.name + id, button_size),
                      [this, button] { answer_input = button.insert; }};
    }

    return output;
}

void
plugin::gui::windows::report::send_chat_action_button() const {
    samp::input::send_command("/a {}[{}]: {}", current_report->nickname,
                              current_report->id, current_report->text);
}

void
plugin::gui::windows::report::block_action_button() {
    if (!can_send_response())
        return;

    ImGui::OpenPopup("block_time_selection");
}

bool
plugin::gui::windows::report::on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) {
    static constexpr types::zstring_t report_information_pattern = R"(Описание репорта:\s+\{FFFFFF\}(.+)\n)";

    if (!dialog || dialog.title != "Обработка репорта")
        return true;

    dialog_active = true;
    dialog_id = dialog.id;

    std::smatch matches;
    std::string dialog_text = dialog.text;

    if (!current_report.has_value())
        return true;

    if (current_report->text.empty() && std::regex_search(dialog_text, matches, std::regex(report_information_pattern))) {
        current_report->time_taken = std::chrono::steady_clock::now();
        current_report->text = matches[1].str();

        open_window();
        
        return false;
    }

    if (!current_response.has_value())
        return false; 

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

bool
plugin::gui::windows::report::on_server_message(const samp::event<samp::event_id::server_message>& message) {
    static constexpr types::zstring_t new_report_pattern
        = R"(^\{FFFF00\}\| \{ffffff\}На вас был назначен репорт от игрока \{4a86b6\}(\S+)\[(\d+)\]\{FFFFFF\})";

    static constexpr types::zstring_t report_canceled_message
        = "{FFFF00}| {ffffff}Обработка репорта завершена.";

    std::smatch matches;

    if (std::regex_search(message.text, matches, std::regex(new_report_pattern)))
        return on_new_report_message(matches[1].str(), std::stoi(matches[2].str()));

    if (message.text.substr(0, std::char_traits<char>::length(report_canceled_message)) == report_canceled_message)
        return on_report_canceled();

    return true;
}

bool
plugin::gui::windows::report::on_new_report_message(const std::string& nickname, std::uint16_t id) {
    auto window_configuration = (*configuration)["windows"]["report"];

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

    if (window_configuration["sound_notify"])
        samp::audio::play_sound(samp::audio::sound_id::bell);

    return true;
}

bool
plugin::gui::windows::report::on_report_canceled() {
    notification_active = false;
    current_report = {};

    if (active)
        close_window();

    auto window_configuration = (*configuration)["windows"]["report"];

    if (window_configuration["notify"])
        notify::send(notification("Обработка репорта завершена",
                                  "Игрок был отсоединен от сервера",
                                  ICON_CLOSE_M_D));

    return true;
}

void
plugin::gui::windows::report::open_window() {
    time_switched_window = std::chrono::steady_clock::now();
    active = focus = true;
    notification_active = false;
}

void
plugin::gui::windows::report::open_window_with_dialog() {
    open_window();
    samp::input::send_command("/greport");
}

void
plugin::gui::windows::report::close_window() {
    time_switched_window = std::chrono::steady_clock::now();
    closing = true;
    child->disable_cursor();

    if (!dialog_active)
        return;

    samp::dialog::send_response(dialog_id, samp::dialog::button::right);
}

void
plugin::gui::windows::report::close_dialog() {
    dialog_active = false;
    samp::dialog::send_response(dialog_id, samp::dialog::button::left);
    close_window();
}

void
plugin::gui::windows::report::switch_window() {
    if (!server::user::is_on_alogin() || !current_report.has_value())
        return;

    (active) ? close_window() : open_window_with_dialog();
}

std::string
plugin::gui::windows::report::get_time_active() const {
    auto duration = std::chrono::steady_clock::now() - current_report->time_taken;
    auto minutes = std::chrono::duration_cast<std::chrono::minutes>(duration);
    
    duration -= minutes;
    
    auto seconds = std::chrono::duration_cast<std::chrono::seconds>(duration);

    return std::format("{:02}:{:02}", minutes.count(), seconds.count());
}

bool
plugin::gui::windows::report::can_send_response() {
    if (answer_input.empty()) {
        time_hint_active = std::chrono::steady_clock::now();
        return false;
    }

    return true;
}

void
plugin::gui::windows::report::send_response(const dialog_option& option) {
    current_response = { option };
    close_dialog();
}

void
plugin::gui::windows::report::send_input_response(const dialog_option& option) {
    if (!can_send_response())
        return;

    current_response = { option, answer_input };
    close_dialog();
}

void
plugin::gui::windows::report::close_report() {
    current_report = {};
    current_response = {};
    dialog_active = false;
    
    answer_input.clear();
    close_window();
}

void
plugin::gui::windows::report::render() {
    if (!active)
        return;

    window_alpha = animation::bring_to(window_alpha, (closing) ? 0 : 255, time_switched_window, animation_duration);
    
    if (!closing && window_alpha != 255 && !child->is_cursor_active())
        child->enable_cursor();

    if (window_alpha == 0 && closing)
        closing = active = false;

    ImGui::PushStyleVar(ImGuiStyleVar_Alpha, window_alpha / 255.f);
    ImGui::SetNextWindowSizeConstraints({ 600, 300 }, { FLT_MAX, FLT_MAX });
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoTitleBar);
    {
        ImGui::BeginChild("context", { 0, ImGui::GetWindowHeight() / 3 }, ImGuiChildFlags_Borders);
        {
            ImGui::BeginGroup();
            {
                widgets::text(bold_font, 0, "{}[{}]", current_report->nickname, current_report->id);
                ImGui::PushFont(regular_font);
                {
                    ImGui::TextWrapped("%s", current_report->text.c_str());
                }
                ImGui::PopFont();
            }
            ImGui::EndGroup();
            ImGui::PushFont(bold_font);
            {
                std::string time_active = get_time_active();
                ImGui::SameLine(ImGui::GetContentRegionAvail().x - ImGui::CalcTextSize(time_active.c_str()).x);
                ImGui::TextUnformatted(time_active.c_str());
            }
            ImGui::PopFont();
        }
        ImGui::EndChild();
        ImGui::PushFont(regular_font);
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

            widgets::hint("Поле ответа не должно быть пустым", style::accent_colors.red)
                .with_condition([this] { return std::chrono::steady_clock::now() - time_hint_active < 5s; })
                .render();
            
            for (const auto& [ index, action_button ] : get_action_buttons() | std::views::enumerate) {
                if (action_button.widget.render())
                    action_button.callback();

                if ((index + 1) % max_buttons_per_line != 0)
                    ImGui::SameLine();
            }

            auto close_button = widgets::button("Ответить##windows::report", { ImGui::GetContentRegionAvail().x, answer_button_height })
                .with_durations({ 200ms, 0ms, 0ms });

            if (close_button.render() && can_send_response())
                send_input_response(dialog_option::answer);
        }
        ImGui::PopFont();

        if (ImGui::BeginPopupModal("block_time_selection", nullptr, ImGuiWindowFlags_NoTitleBar)) {
            widgets::text(bold_font, 0, "Выберите время блокировки");
            ImGui::PushFont(regular_font);
            {
                float full_width = ImGui::GetContentRegionAvail().x;
               
                for (std::uint8_t index = 0; index < std::size(block_time_options); index++) {
                    auto button = widgets::button(std::to_string(block_time_options[index]) + " минут##block_time_selection", { full_width, 25 })
                        .with_durations({ 200ms, 0ms, 0ms });

                    if (button.render()) {
                        current_response = { dialog_option::block, answer_input, index };
                        ImGui::CloseCurrentPopup();
                        close_dialog();
                    }
                }
            
                if (widgets::button("Закрыть##block_time_selection", { full_width, 30 })
                        .with_durations({ 200ms, 0ms, 0ms })
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

bool
plugin::gui::windows::report::on_event(const samp::event_info& event) {
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

plugin::gui::window_ptr_t
plugin::gui::windows::report::create(types::not_null<gui_initializer*> child) noexcept {
    return std::make_unique<report>(child);
}

plugin::gui::windows::report::report(types::not_null<gui_initializer*> child)
    : child(child),
      bold_font((*child->fonts->bold)[18]),
      regular_font((*child->fonts->regular)[16])
{
    log::info("window \"windows::report\" initialized");

    switch_window_hotkey = hotkey("Открыть/закрыть окно репорта", key_bind({ 'K', 0 }, bind_condition::on_alogin))
        .with_callback(std::bind(&report::switch_window, this));

    child->hotkey_handler->add(switch_window_hotkey);
}
