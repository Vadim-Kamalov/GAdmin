#include "plugin/server/admins.h"
#include "plugin/server/user.h"
#include "plugin/samp/core/user.h"
#include "plugin/log.h"
#include "plugin/plugin.h"
#include <algorithm>
#include <regex>
#include <spanstream>

void
plugin::server::admin::sort(std::vector<admin>& admins, const sort_option& option) {
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

bool
plugin::server::admins::on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) {
    if (!list.empty() || user::is_on_alogin())
        return true;

    if (std::regex_search(dialog.text, std::regex("Лог отключений"))) {
        dialog.send_response(samp::dialog::button::right, 0);
        return false;
    }

    if (std::regex_search(dialog.text, std::regex("Администраторы в сети:"))) {
        update_admins(dialog.text);

        if ((*configuration)["user"]["nickname"] == "Администратор" && (*configuration)["user"]["level"] == 0) {
            (*configuration)["user"]["nickname"] = "Technical Admin";
            (*configuration)["user"]["level"] = 6;
        }
        
        log::info("user is on /alogin; admins::list is not empty and available now");
        user::set_alogin_status(true);
    
        return false;
    }

    return true;
}

bool
plugin::server::admins::on_server_message(const samp::event<samp::event_id::server_message>& message) {
    std::smatch matches;
    
    if (std::regex_search(message.text, matches, std::regex(R"(^\[A\] (\S+)\[(\d+)\] авторизовался как администратор (\d+) уровня.$)"))) {
        std::string nickname = matches[1].str();
        std::uint16_t id = static_cast<std::uint16_t>(std::stoul(matches[2].str()));
        std::uint8_t level = static_cast<std::uint8_t>(std::stoul(matches[3].str()));

        add_connected_admin({ nickname, id, level });

        return true;
    }

    if (std::regex_search(message.text, matches, std::regex(R"(^\[A\] \S+\[(\d+)\] вышел как администратор.$)")))
        remove_disconnected_admin(static_cast<std::uint16_t>(std::stoul(matches[1].str())));

    return true;
}

bool
plugin::server::admins::on_server_quit(const samp::event<samp::event_id::server_quit>& disconnected) {
    remove_disconnected_admin(disconnected.id);
    return true;
}

bool
plugin::server::admins::on_set_player_name(const samp::event<samp::event_id::set_player_name>& player) {
    remove_disconnected_admin(player.id);
    return true;
}

void
plugin::server::admins::update_admins(const std::string_view& dialog_text) {
    std::ispanstream stream(dialog_text);
    for (std::string line; std::getline(stream, line);) {
        std::smatch matches;
        if (std::regex_search(line, matches, std::regex(R"(\{FFFFFF\}(.*)\[(\d+)\] - ([1-5]) уровень)"))) {
            std::string nickname = matches[1].str();
            std::uint16_t id = static_cast<std::uint16_t>(std::stoul(matches[2].str()));
            std::uint8_t level = static_cast<std::uint8_t>(std::stoul(matches[3].str()));
                
            if (id == samp::user::get_id()) {
                (*configuration)["user"]["nickname"] = nickname;
                (*configuration)["user"]["level"] = level;
            }

            list.push_back({ nickname, id, level });
        }
    }
}

void
plugin::server::admins::add_connected_admin(const admin& connected_admin) {
    if (get_admin(connected_admin.id).has_value())
        return;

    list.push_back(connected_admin);
}

void
plugin::server::admins::remove_disconnected_admin(std::uint16_t id) {
    if (id == samp::user::get_id()) {
        user::set_alogin_status(false);
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

std::optional<plugin::server::admin>
plugin::server::admins::get_admin(std::uint16_t id) {
    if (auto found = std::find_if(list.begin(), list.end(), [id](const admin& it) { return it.id == id; }); found != list.end())
        return *found;
    else
        return {};
}

void
plugin::server::admins::on_alogout() {
    list.clear();
}

bool
plugin::server::admins::on_event(const samp::event_info& event) {
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
