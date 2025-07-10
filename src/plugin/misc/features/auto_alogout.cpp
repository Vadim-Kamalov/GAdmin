#include "plugin/misc/features/auto_alogout.h"
#include "plugin/samp/core/input.h"
#include "plugin/server/user.h"
#include "plugin/game/game.h"
#include "plugin/string_utils.h"
#include "plugin/types/simple.h"
#include "plugin/memory.h"
#include "plugin/plugin.h"
#include <cstring>
#include <windows.h>

auto plugin::misc::features::auto_alogout::send_shell_notification(const std::string& text) const
    -> void
{
    NOTIFYICONDATA notify_data;
    
    notify_data.cbSize = sizeof(NOTIFYICONDATA);
    notify_data.hWnd = game::get_window();
    notify_data.uID = 1;
    notify_data.uFlags = NIF_INFO | NIF_ICON;
    notify_data.dwInfoFlags = NIIF_USER | NIIF_LARGE_ICON;
    notify_data.hIcon = LoadIconA(nullptr, IDI_WARNING);

    std::strcpy(notify_data.szInfoTitle, "GAdmin v" PROJECT_VERSION);
    std::strcpy(notify_data.szInfo, string_utils::to_cp1251(text).c_str());

    notify_data.uTimeout = 10000;

    Shell_NotifyIconA(NIM_ADD, &notify_data);
    Shell_NotifyIconA(NIM_MODIFY, &notify_data);
}

auto plugin::misc::features::auto_alogout::set_background_work_state(bool state) const -> void {
    memory::write<std::uint8_t>(0x747FB6, state);
    memory::write<std::uint8_t>(0x74805A, state);

    if (state) {
        memory::set(0x53EA88, 0x90, 6);
        memory::set(0x74542B, 0x90, 8);
        return;
    }

    // jz loc_53EC09 ; Jump if Zero (ZF=1)
    memory::copy(0x53EA88, { 0x0F, 0x84, 0x7B, 0x01, 0x00, 0x00 });
    
    // push eax                   ; Y
    // push ecx                   ; X
    // call ds:__imp_SetCursorPos ; Indirect Call Near Procedure
    memory::copy(0x74542B, { 0x50, 0x51, 0xFF, 0x15, 0x00, 0x83, 0x85, 0x00 });
}

auto plugin::misc::features::auto_alogout::on_event(unsigned int message, WPARAM, LPARAM) -> bool {
    if (message != WM_KILLFOCUS && message != WM_SETFOCUS)
        return true;

    game_focused = message == WM_SETFOCUS;

    return true;
}

auto plugin::misc::features::auto_alogout::on_alogin_new_state(bool state) -> void {
    set_background_work_state(state);
}

auto plugin::misc::features::auto_alogout::main_loop() -> void {
    auto feature_configuration = (*configuration)["misc"]["auto_alogout"];

    if (!feature_configuration["use"])
        return;

    if (!server::user::is_on_alogin() || (!game::is_menu_opened() && game_focused)) {
        if (seconds_inactive != 0s) {
            seconds_inactive = 0s;
            sent_warning_notification = false;
        }

        return;
    }

    auto now = std::chrono::steady_clock::now();

    if (now - time_updated >= 1s) {
        seconds_inactive += 1s;
        time_updated = now;
    }

    std::size_t seconds_until_warning = feature_configuration["seconds_until_warning"];
    std::size_t seconds_until_alogout = feature_configuration["seconds_until_alogout"];

    if (seconds_inactive == std::chrono::seconds(seconds_until_warning) && !sent_warning_notification) {
        static constexpr types::zstring_t notification_text = 
            "Вы провели в AFK на /alogin {} секунд. У вас есть еще {}"
            "секунд что-бы зайти, иначе плагин скрипт сам покинет дежурство.";

        send_shell_notification(std::format(notification_text, seconds_until_warning,
                                            seconds_until_alogout - seconds_until_warning));
        
        sent_warning_notification = true;

        return;
    }

    if (seconds_inactive != std::chrono::seconds(seconds_until_alogout))
        return;

    static constexpr types::zstring_t notification_text =
        "Вы провели в AFK на /alogin {} секунд. Плагин автоматически покинул дежурство";

    server::user::set_alogin_status(false);
    samp::input::send_command("/alogout");
    send_shell_notification(std::format(notification_text, seconds_until_alogout));
}

plugin::misc::features::auto_alogout::~auto_alogout() noexcept {
    set_background_work_state(false);
}
