#include "plugin/server/user.h"
#include "plugin/server/admins.h"
#include "plugin/samp/core/input.h"
#include "plugin/log.h"
#include <regex>

void
plugin::server::User::set_alogin_status(bool status) {
    on_alogin = status;

    log::info("User::set_alogin_status({})", status);

    if (status)
        return;

    Admins::on_alogout();
}

bool
plugin::server::User::on_show_dialog(const samp::Dialog& dialog) {
    if (dialog.title == "Выбор персонажа" && is_on_alogin())
        set_alogin_status(false);

    return true;
}

bool
plugin::server::User::on_server_message(const samp::ServerMessage& message) {
    static constexpr const char* authorization_pattern = 
        "Вы успешно авторизовались как администратор|"
        "Вы уже авторизировались|"
        "Вы успешно авторизовались как ведущий администратор|"
        "Вы успешно авторизовались как разработчик";

    static constexpr const char* alogout_pattern =
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
plugin::server::User::main_loop() {
    if (can_send_command) {
        samp::input::send_command("/adm");
        can_send_command = false;
    }
}

bool
plugin::server::User::on_event(const samp::EventType& type, std::uint8_t id, samp::BitStream* bit_stream) {
    if (type == samp::EventType::IncomingPacket && (id == 32 || id == 36 || id == 37) && !is_on_alogin())
        set_alogin_status(false);

    if (type == samp::EventType::IncomingRPC && id == samp::Dialog::event_id)
        if (samp::Dialog dialog = samp::Dialog(bit_stream); dialog.valid)
            return on_show_dialog(dialog);

    if (type == samp::EventType::IncomingRPC && id == samp::ServerMessage::event_id)
        return on_server_message(samp::ServerMessage(bit_stream));

    return true;
}
