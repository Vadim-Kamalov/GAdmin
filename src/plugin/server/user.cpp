#include "plugin/server/user.h"
#include "plugin/server/admins.h"
#include "plugin/samp/core/input.h"
#include "plugin/samp/core/user.h"
#include "plugin/types/u8regex.h"
#include "plugin/plugin.h"

void
plugin::server::user::set_alogin_status(bool status) {
    on_alogin = status;

    cheats_initializer->on_alogin_new_state(status);

    if (status)
        return;

    admins::on_alogout();
}

bool
plugin::server::user::on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) {
    if (dialog.title == "Выбор персонажа" && is_on_alogin())
        set_alogin_status(false);

    return true;
}

bool
plugin::server::user::on_server_message(const samp::event<samp::event_id::server_message>& message) {
    static std::array<std::string, 4> authorization_strings = { 
        "Вы успешно авторизовались как администратор",
        "Вы уже авторизировались",
        "Вы успешно авторизовались как ведущий администратор",
        "Вы успешно авторизовались как разработчик"
    }; // static std::array<std::string, 4> authorization_strings

    static constexpr ctll::fixed_string alogout_pattern =
        "^\\{FFFF00\\}\\| \\{ffffff\\}За сессию администратирования вы заработали "
        "\\{4a86b6\\}\\d+ \\{FFFFFF\\}GMoney.$";

    static constexpr ctll::fixed_string admin_chat_message_pattern = R"(^\[A\] (\S+)\[(\d+)\]: )";

    if (std::find_if(authorization_strings.begin(), authorization_strings.end(), [message](const std::string& str) {
        return message.text.contains(str);
    }) != authorization_strings.end() && message.color == 0xFFFFFFFF && !is_on_alogin()) {
        auto now = std::chrono::steady_clock::now();
        if (now - last_time_authorized >= std::chrono::milliseconds(SERVER_COMMAND_DELAY_MS)) {
            last_time_authorized = now;
            can_send_command = true;
            return true;
        }
    }

    if (types::u8regex::search<alogout_pattern>(message.text) && is_on_alogin())
        set_alogin_status(false);

    if (auto [ whole, nickname, id_match ] = ctre::search<admin_chat_message_pattern>(message.text); whole) {
        if (samp::user::get_id() != std::stoul(id_match.str()))
            return true;

        auto& user_information = (*configuration)["user"];
        std::string user_ooc_nickname = user_information["nickname"];
        std::uint8_t user_level = user_information["level"];

        if (user_ooc_nickname == "Администратор" && user_level == 6)
            user_information["nickname"] = nickname;
    }

    return true;
}

void
plugin::server::user::main_loop() {
    if (can_send_command) {
        samp::input::send_command("/adm");
        can_send_command = false;
    }
}

bool
plugin::server::user::on_event(const samp::event_info& event) {
    if (event == samp::event_type::incoming_packet && is_on_alogin() && (event.id == 32 || event.id == 36 || event.id == 37))
        set_alogin_status(false);

    if (event == samp::event_type::incoming_rpc) {
        if (event == samp::event_id::server_message)
            return on_server_message(event.create<samp::event_id::server_message>());
        else if (event == samp::event_type::incoming_rpc && event == samp::event_id::show_dialog) {
            if (auto dialog_event = event.create<samp::event_id::show_dialog>()) {
                return on_show_dialog(dialog_event);
            }
        }
    }

    return true;
}
