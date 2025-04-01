#include "plugin/gui/windows/command_requester.h"
#include "plugin/samp/core/player_pool.h"
#include "plugin/types/string_iterator.h"
#include "plugin/samp/core/input.h"
#include "plugin/samp/core/user.h"
#include "plugin/server/user.h"
#include "plugin/gui/notify.h"
#include "plugin/game/game.h"
#include "plugin/plugin.h"
#include "plugin/log.h"
#include <algorithm>
#include <cctype>
#include <regex>

const std::vector<plugin::gui::windows::command_requester::command_t> plugin::gui::windows::command_requester::commands = {
    { command_t::type_t::answer, "pk", 2, { command_t::param_t::id }},
    { command_t::type_t::answer, "ck", 3, { command_t::param_t::id }},
    { command_t::type_t::answer, "slap", 2, { command_t::param_t::id }},
    { command_t::type_t::answer, "unfreeze", 2, { command_t::param_t::id }},
    { command_t::type_t::answer, "setworld", 2, { command_t::param_t::id, command_t::param_t::number }},
    { command_t::type_t::answer, "setint", 2, { command_t::param_t::id, command_t::param_t::number }},
    { command_t::type_t::answer, "dpame", 2, { command_t::param_t::id }},
    { command_t::type_t::answer, "leave", 3, { command_t::param_t::id }},
    { command_t::type_t::answer, "makemic", 3, { command_t::param_t::id, command_t::param_t::number_optional }},
    { command_t::type_t::answer, "unwarn", 5, { command_t::param_t::id }},
    { command_t::type_t::answer, "aheal", 3, { command_t::param_t::id }},
    { command_t::type_t::reason, "warn", 2, { command_t::param_t::id, command_t::param_t::text }},
    { command_t::type_t::reason, "kick", 2, { command_t::param_t::id, command_t::param_t::text }},
    { command_t::type_t::reason, "ban", 3, { command_t::param_t::id, command_t::param_t::number, command_t::param_t::text }},
    { command_t::type_t::reason, "mute", 2, { command_t::param_t::id, command_t::param_t::number, command_t::param_t::text }},
    { command_t::type_t::reason, "bmute", 2, { command_t::param_t::id, command_t::param_t::number, command_t::param_t::text }},
    { command_t::type_t::reason, "iban", 4, { command_t::param_t::id, command_t::param_t::text }},
    { command_t::type_t::reason, "jail", 2, { command_t::param_t::id, command_t::param_t::number, command_t::param_t::text }},
    { command_t::type_t::none, "vspawn", 2, { command_t::param_t::number }},
    { command_t::type_t::none, "vfuel", 3, { command_t::param_t::number, command_t::param_t::number }},
    { command_t::type_t::none, "dvehid", 4, { command_t::param_t::number }}
}; // const std::vector<plugin::gui::windows::command_requester::command_t> plugin::gui::windows::command_requester::commands

std::optional<plugin::gui::windows::command_requester::parsed_request_t>
plugin::gui::windows::command_requester::try_parse_request(const std::string_view& usage) const {
    std::optional<std::uint16_t> receiver_id;

    for (const auto& request_command : commands) {
        if (usage.substr(1, request_command.name.length()) != request_command.name)
            continue;

        types::string_iterator iterator(usage, request_command.name.length() + 1 /* '/' sign */);

        if (!iterator.current().has_value() || !std::isspace(*iterator.current()))
            return {};
    
        iterator.skip(::isspace);

        for (const auto& param : request_command.params) {
            if (!iterator.current().has_value() && param != command_t::param_t::number_optional)
                return {};

            std::string argument = iterator.collect([](unsigned char c) { return !std::isspace(c); });
            
            iterator.skip(::isspace);

            if (param == command_t::param_t::number_optional && !std::isdigit(argument[0])) {
                if (iterator.current().has_value()) // `param_t::number_optional` must always be the last argument
                    return {};
                
                return parsed_request_t(request_command, receiver_id);
            }

            if (param != command_t::param_t::text && !std::all_of(argument.begin(), argument.end(), ::isdigit))
                return {};
            
            if (param == command_t::param_t::id) {
                try {
                    std::uint16_t new_receiver_id = std::stoul(argument);

                    if (!samp::player_pool::is_connected(new_receiver_id))
                        return {};

                    receiver_id = new_receiver_id;
                } catch (const std::exception& e) {
                    log::warn("std::exception in command_requester::is_valid_command_usage (with usage = \"{}\"): {}",
                              usage, e.what());
                    return {};
                }
            }
        
            if (param == command_t::param_t::text)
                return parsed_request_t(request_command, receiver_id);
        }

        if (iterator.current().has_value())
            return {};

        return parsed_request_t(request_command, receiver_id);
    }

    return {};
}

bool
plugin::gui::windows::command_requester::on_send_command(const samp::out_event<samp::event_id::send_command>& event) {
    last_command = event.command;
    return true;
}

bool
plugin::gui::windows::command_requester::on_server_message(const samp::event<samp::event_id::server_message>& event) {
    if (!server::user::is_on_alogin())
        return true;

    if (event.text == "{AA3333}| {ffffff}У Вас нет доступа для использования данной команды." &&
        !last_command.empty() && try_parse_request(last_command).has_value())
    {
        command_to_send = "/a " + last_command;
        time_to_send_command = std::chrono::steady_clock::now() + std::chrono::milliseconds(SERVER_COMMAND_DELAY_MS);
        
        last_command.clear();

        return true;
    }

    if (event.color == 0xAA33AA33 && try_handle_new_request(event.text))
        return true;

    if (try_handle_approved_request(event.text, event.color))
        return true;

    return true;
}

bool
plugin::gui::windows::command_requester::try_handle_new_request(const std::string& text) {
    static constexpr types::zstring_t command_request_pattern = R"(\[A\] (.+)\[(\d+)\]: (/.*))";

    std::smatch matches;

    if (std::regex_match(text, matches, std::regex(command_request_pattern))) {
        std::string sender_nickname = matches[1].str();
        std::uint16_t sender_id = std::stoi(matches[2].str());
        std::string command = matches[3].str();

        if (sender_id == samp::user::get_id())
            return false;

        if (auto request_command = try_parse_request(command); request_command.has_value()) {
            time_request_sent = std::chrono::steady_clock::now();
            current_request = { request_command->receiver_id, sender_nickname,
                                sender_id, command, request_command->command };

            auto command_requester_configuration = (*configuration)["additions"]["command_requester"];

            if (command_requester_configuration["use"] && !command_requester_configuration["notify_by_window"]) {
                std::string description = std::format("Команда: {}. Принять можно в течении 5 секунд биндом на {}",
                                                      command, approve_request_hotkey.bind);

                notification::button first_button = { "Принять", [&](auto) { approve_request(); } };
                notification::button second_button = { "Закрыть", [&](notification& it) { it.remove(); } };

                gui::notify::send(notification("Запрос команды от " + sender_nickname, description, ICON_CHAT_CIRCLE_CHECK)
                        .with_buttons(first_button, second_button)
                        .with_condition([this]{ return current_request.has_value(); }));
            }
            
            return true;
        }
    }

    return false;
}

bool
plugin::gui::windows::command_requester::try_handle_approved_request(const std::string& text, const types::color& color) {
    if (!current_request.has_value())
        return false;

    static constexpr types::zstring_t answer_request_pattern = R"(\[A\] .+\[\d+\] ответил .+\[\d+\]: \S+ by (.+))";
    static constexpr types::zstring_t reason_request_pattern = R"(Администратор .+\. Причина: .+ // (.+))";
    static constexpr types::zstring_t none_request_pattern = R"(\[A\] .+\[\d+\]: (\d+), \+)";

    std::smatch matches;
    std::regex regex;
    std::string to_compare = current_request->sender_nickname;

    switch (current_request->command.type) {
        case command_t::type_t::answer:
            regex = std::regex(answer_request_pattern);
            break;
        case command_t::type_t::reason:
            regex = std::regex(reason_request_pattern);
            break;
        case command_t::type_t::none: {
            if (color != 0xAA33AA33)
                return false;

            regex = std::regex(none_request_pattern);
            to_compare = std::to_string(current_request->sender_id);

            break;
        }
    }

    if (std::regex_match(text, matches, regex) && matches[1].str() == to_compare) {
        current_request = {};
        return true;
    }

    return false;
}

void
plugin::gui::windows::command_requester::approve_request() {
    auto user_level = (*configuration)["user"]["level"];

    if (!current_request.has_value() || user_level < current_request->command.level)
        return;

    switch (current_request->command.type) {
        case command_t::type_t::reason:
            samp::input::send_command("{} // {}", current_request->full_command, current_request->sender_nickname);
            return;
        case command_t::type_t::none:
            samp::input::send_command("/a {}, +", current_request->sender_id);
            break;
        case command_t::type_t::answer: {
            if (!current_request->receiver_id.has_value())
                return;

            std::string command_name = current_request->command.name;

            std::transform(command_name.begin(), command_name.end(),
                           command_name.begin(), ::toupper);

            samp::input::send_command("/ans {} {} by {}", *current_request->receiver_id, 
                                      command_name, current_request->sender_nickname);

            break;
        }
    }

    command_to_send = current_request->full_command;
    time_to_send_command = std::chrono::steady_clock::now() + std::chrono::milliseconds(SERVER_COMMAND_DELAY_MS);
    current_request = {};
}

void
plugin::gui::windows::command_requester::render() {
    using namespace std::chrono_literals;

    auto now = std::chrono::steady_clock::now();

    if (!command_to_send.empty() && now >= time_to_send_command) {
        samp::input::send_command("{}", command_to_send);
        command_to_send = "";
    }

    if (current_request.has_value() && now - time_request_sent >= 5s)
        current_request = {};
    
    auto command_requester_configuration = (*configuration)["additions"]["command_requester"];
    auto user_level = (*configuration)["user"]["level"];

    if (!command_requester_configuration["use"] ||
        !command_requester_configuration["notify_by_window"] ||
        !current_request.has_value() ||
        user_level < current_request->command.level ||
        !server::user::is_on_alogin())
    {
        return;
    }

    ImVec2 padding = ImGui::GetStyle().WindowPadding;
    auto [ size_x, size_y ] = game::get_screen_resolution();
    float window_height = bold_font->FontSize + padding.y * 2;

    auto time_to_hide_ms = std::chrono::duration_cast<std::chrono::milliseconds>(5s - (now - time_request_sent));
    std::string timer = std::format("Запрос истекает через {:.1f} секунд", time_to_hide_ms.count() / 1000.f);

    ImGui::SetNextWindowSize({ size_x, window_height });
    ImGui::SetNextWindowPos({ 0, size_y - window_height });
    ImGui::SetNextWindowBgAlpha(0.5);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 0);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0);
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoMove);
    {
        ImGui::PushFont(regular_font);
        {
            ImGui::TextUnformatted(std::format("Запрос команды от {} · Принять - {}",
                                               current_request->sender_nickname,
                                               approve_request_hotkey.bind).c_str());

            ImGui::PushFont(bold_font);
            {
                ImGui::SameLine((size_x - ImGui::CalcTextSize(current_request->full_command.c_str()).x) / 2);
                ImGui::TextUnformatted(current_request->full_command.c_str());
            }
            ImGui::PopFont();

            ImGui::SameLine(size_x - ImGui::CalcTextSize(timer.c_str()).x - padding.x);
            ImGui::TextUnformatted(timer.c_str());
        }
        ImGui::PopFont();
    }
    ImGui::End();
    ImGui::PopStyleVar(2);
}

bool
plugin::gui::windows::command_requester::on_event(const samp::event_info& event) {
    if (event == samp::event_type::outgoing_rpc && event == samp::event_id::send_command)
        return on_send_command(event.create<samp::event_id::send_command, samp::event_type::outgoing_rpc>());

    if (event == samp::event_type::incoming_rpc && event == samp::event_id::server_message)
        return on_server_message(event.create<samp::event_id::server_message>());

    return true;
}

plugin::gui::window_ptr_t
plugin::gui::windows::command_requester::create(types::not_null<gui_initializer*> child) noexcept {
    return std::make_unique<command_requester>(child);
}

plugin::gui::windows::command_requester::command_requester(types::not_null<gui_initializer*> child)
    : child(child),
      regular_font((*child->fonts->regular)[18]),
      bold_font((*child->fonts->bold)[18])
{
    approve_request_hotkey = hotkey("Принятие формы", key_bind({ 'L', 0 }, bind_condition::on_alogin))
        .with_callback([this](auto) { approve_request(); });

    child->hotkey_handler->add(approve_request_hotkey);
    
    log::info("window \"windows::command_requester\" initialized");
}
