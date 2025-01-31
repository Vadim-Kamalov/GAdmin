#include "plugin/server/user.h"
#include "plugin/server/admins.h"
#include "plugin/samp/core/input.h"
#include "plugin/log.h"
#include <regex>

void
plugin::server::user::set_alogin_status(bool status) {
    on_alogin = status;

    log::info("user::set_alogin_status({})", status);

    if (status)
        return;

    admins::on_alogout();
}

bool
plugin::server::user::on_show_dialog(const samp::dialog& dialog) {
    if (dialog.title == "Выбор персонажа" && is_on_alogin())
        set_alogin_status(false);

    return true;
}

bool
plugin::server::user::on_server_message(const samp::server_message& message) {
    static constexpr utils::zstring_t authorization_pattern = 
        "Вы успешно авторизовались как администратор|"
        "Вы уже авторизировались|"
        "Вы успешно авторизовались как ведущий администратор|"
        "Вы успешно авторизовались как разработчик";

    static constexpr utils::zstring_t alogout_pattern =
        "^\\{FFFF00\\}\\| \\{ffffff\\}За сессию администратирования вы заработали "
        "\\{4a86b6\\}\\d+ \\{FFFFFF\\}GMoney.$";

    if (std::regex_search(message.text, std::regex(authorization_pattern)) && message.color == 0xFFFFFFFF && !is_on_alogin()) {
        auto now = std::chrono::steady_clock::now();
        if (now - last_time_authorized >= std::chrono::milliseconds(SERVER_COMMAND_DELAY_MS)) {
            last_time_authorized = now;
            can_send_command = true;
            return true;
        }
    }

    if (std::regex_search(message.text, std::regex(alogout_pattern)) && is_on_alogin())
        set_alogin_status(false);

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
plugin::server::user::on_event(const samp::event_type& type, std::uint8_t id, samp::bit_stream* stream) {
    if (type == samp::event_type::incoming_packet && (id == 32 || id == 36 || id == 37) && is_on_alogin())
        set_alogin_status(false);

    if (type == samp::event_type::incoming_rpc && id == samp::dialog::event_id)
        if (samp::dialog dialog = samp::dialog(stream); dialog.valid)
            return on_show_dialog(dialog);

    if (type == samp::event_type::incoming_rpc && id == samp::server_message::event_id)
        return on_server_message(samp::server_message(stream));

    return true;
}
