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

#include "plugin/server/admins.h"
#include "plugin/server/user.h"
#include "plugin/samp/core/user.h"
#include "plugin/log.h"
#include "plugin/plugin.h"
#include "plugin/string_utils.h"
#include "plugin/types/u8regex.h"
#include <algorithm>
#include <spanstream>

auto plugin::server::admin::sort(std::vector<admin>& admins, const sort_option& option) -> void {
    switch (option) {
        case sort_option::disabled:
            break;
        case sort_option::length:
            std::ranges::sort(admins, [](const admin& a, const admin& b) { return a.nickname.length() < b.nickname.length(); });
            break;
        case sort_option::id:
            std::ranges::sort(admins, {}, &admin::id);
            break;
        case sort_option::level:
            std::ranges::sort(admins, {}, &admin::level);
            break;
    }
}

auto plugin::server::admins::on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool {
    if (user::is_on_alogin())
        return true;

    if (dialog.text.contains("Лог отключений")) {
        dialog.send_response(samp::dialog::button::right, 0);
        return false;
    }

    if (dialog.title == "Администрация онлайн") {
        std::string raw_dialog_text = string_utils::remove_samp_colors(dialog.text);

        update_admins(raw_dialog_text);

        // if (raw_dialog_text.contains("Следующая страница")) {
        //     dialog.send_response(samp::dialog::button::right, next_page_list_item_index);
        //     return false;
        // }

        auto& user_information = (*configuration)["user"];

        if (user_information["nickname"] == "Администратор" && user_information["level"] == 0) {
            user_information["nickname"] = "Technical Admin";
            user_information["level"] = 6;
        }
        
        log::info("user is on /alogin; admins::list is not empty and available now");
        user::set_alogin_state(true);
    
        return false;
    }

    return true;
}

auto plugin::server::admins::on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool {
    static constexpr ctll::fixed_string authorization_pattern = 
        R"(\[A\] (\S+)\[(\d+)\] авторизовался как администратор (\d+) уровня.)";

    static constexpr ctll::fixed_string disconnect_pattern
        = R"(\[A\d\] \S+\[(\d+)\] вышел как администратор.)";
    
    if (auto matches = types::u8regex::match<authorization_pattern>(message.text)) {
        std::string nickname = matches.get_string<1>();
        std::uint16_t id = static_cast<std::uint16_t>(std::stoul(matches.get_string<2>()));
        std::uint8_t level = static_cast<std::uint8_t>(std::stoul(matches.get_string<3>()));

        add_connected_admin({ nickname, id, level });

        return true;
    }

    if (auto matches = types::u8regex::match<disconnect_pattern>(message.text))
        remove_disconnected_admin(static_cast<std::uint16_t>(std::stoul(matches.get_string<1>())));

    return true;
}

auto plugin::server::admins::on_server_quit(const samp::event<samp::event_id::server_quit>& disconnected) -> bool {
    remove_disconnected_admin(disconnected.id);
    return true;
}

auto plugin::server::admins::on_set_player_name(const samp::event<samp::event_id::set_player_name>& player) -> bool {
    remove_disconnected_admin(player.id);
    return true;
}

auto plugin::server::admins::update_admins(const std::string_view& dialog_text) -> void {
    static constexpr ctll::fixed_string entry_pattern = R"((.*) \(([1-5]) уровень\).+\((\d+)\))";

    std::ispanstream stream(dialog_text);

    for (std::string entry; std::getline(stream, entry);) {
        if (auto matches = types::u8regex::search<entry_pattern>(entry)) {
            std::string nickname = matches.get_string<1>();
            std::uint8_t level = static_cast<std::uint8_t>(std::stoul(matches.get_string<2>()));
            std::uint16_t id = static_cast<std::uint16_t>(std::stoul(matches.get_string<3>()));
                
            if (id == samp::user::get_id()) {
                auto& user_information = (*configuration)["user"];
                user_information["nickname"] = nickname;
                user_information["level"] = level;
            }

            list.push_back({ nickname, id, level });
        }
    }
}

auto plugin::server::admins::add_connected_admin(const admin& connected_admin) -> void {
    if (get_admin(connected_admin.id).has_value())
        return;

    list.push_back(connected_admin);
}

auto plugin::server::admins::remove_disconnected_admin(std::uint16_t id) -> void {
    if (id == samp::user::get_id()) {
        user::set_alogin_state(false);
        return;
    }

    for (auto it = list.begin(); it != list.end();) { 
        if (it->id == id) {
            it = list.erase(it);
            return;
        } else {
            it++;
        }
    }
}

auto plugin::server::admins::get_admin(std::uint16_t id) -> std::optional<admin> {
    if (auto found = std::find_if(list.begin(), list.end(), [id](const admin& it) { return it.id == id; }); found != list.end())
        return *found;
    else
        return {};
}

auto plugin::server::admins::on_alogout() -> void {
    list.clear();
}

auto plugin::server::admins::on_event(const samp::event_info& event) -> bool {
    if (event == samp::event_type::incoming_rpc) {
        if (event == samp::event_id::show_dialog)
            if (auto dialog_event = event.create<samp::event_id::show_dialog>())
                return on_show_dialog(dialog_event);

        if (event == samp::event_id::server_message)
            return on_server_message(event.create<samp::event_id::server_message>());
    
        if (event == samp::event_id::server_quit)
            return on_server_quit(event.create<samp::event_id::server_quit>());

        if (event == samp::event_id::set_player_name)
            return on_set_player_name(event.create<samp::event_id::set_player_name>());
    }

    return true;
}
