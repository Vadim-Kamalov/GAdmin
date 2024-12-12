#include "plugin/server/admins.h"
#include "plugin/server/user.h"
#include "plugin/samp/core/user.h"
#include "plugin/log.h"
#include "plugin/plugin.h"
#include <algorithm>
#include <regex>

void
plugin::server::Admin::sort(std::vector<Admin>& admins, const SortOption& sort_option) {
    switch (sort_option) {
        case SortOption::Disabled:
            break;
        case SortOption::Length:
            std::ranges::sort(admins, [](const Admin& a, const Admin& b) { return a.nickname.length() < b.nickname.length(); });
            break;
        case SortOption::Id:
            std::ranges::sort(admins, {}, &Admin::id);
            break;
        case SortOption::Level:
            std::ranges::sort(admins, {}, &Admin::level);
            break;
    }
}

bool
plugin::server::Admin::sort(std::vector<Admin>& admins, const std::string_view& option) {
    static std::unordered_map<std::string_view, SortOption> options = {
        { "default", SortOption::Disabled },
        { "length", SortOption::Length },
        { "id", SortOption::Id },
        { "level", SortOption::Level }
    };

    if (!options.contains(option)) {
        log::warn("failed to Admin::sort(std::vector<Admins>&, (const std::string_view&) \"{}\"): invalid option", option);
        return false;
    }

    sort(admins, options[option]);
    
    return true;
}

bool
plugin::server::Admins::on_show_dialog(const samp::Dialog& dialog) {
    if (!list.empty() || User::is_on_alogin())
        return true;

    if (std::regex_search(dialog.text, std::regex("Лог отключений"))) {
        dialog.send_response<1, 0>();
        return false;
    }

    if (std::regex_search(dialog.text, std::regex("Администраторы в сети:"))) {
        std::istringstream stream(dialog.text);
        std::string line;

        while (std::getline(stream, line)) {
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

        if ((*configuration)["user"]["nickname"] == "Администратор" && (*configuration)["user"]["level"] == 0) {
            (*configuration)["user"]["nickname"] = "Technical Admin";
            (*configuration)["user"]["level"] = 6;
        }
        
        log::info("user is on /alogin; Admins::list is not empty and available now");
        User::set_alogin_status(true);
    
        return false;
    }

    return true;
}

bool
plugin::server::Admins::on_server_message(const samp::ServerMessage& message) {
    std::smatch matches;
    
    if (std::regex_search(message.text, matches, std::regex(R"(^\[A\] (\S+)\[(\d+)\] авторизовался как администратор (\d+) уровня.$)"))) {
        std::string nickname = matches[1].str();

        if (std::find_if(list.begin(), list.end(), [&nickname](Admin admin) {
            return admin.nickname == nickname;
        }) == std::end(list)) {
            std::uint16_t id = static_cast<std::uint16_t>(std::stoul(matches[2].str()));
            std::uint8_t level = static_cast<std::uint8_t>(std::stoul(matches[3].str()));

            list.push_back({ nickname, id, level });
        }

        return true;
    }

    if (std::regex_search(message.text, matches, std::regex(R"(^\[A\] \S+\[(\d+)\] вышел как администратор.$)"))) {
        std::uint16_t id = static_cast<std::uint16_t>(std::stoul(matches[1].str()));

        if (id == samp::user::get_id()) {
            User::set_alogin_status(false);
            return true;
        }

        for (auto it = list.begin(); it != list.end();) { 
            if (it->id == id) {
                it = list.erase(it);
                return true;
            } else {
                it++;
            }
        }
    }

    return true;
}

void
plugin::server::Admins::on_alogout() {
    list.clear();
}

bool
plugin::server::Admins::on_event(const samp::EventType& type, std::uint8_t id, samp::BitStream* bit_stream) {
    if (type == samp::EventType::IncomingRPC && id == samp::Dialog::event_id)
        if (samp::Dialog dialog = samp::Dialog(bit_stream); dialog.valid)
            return on_show_dialog(dialog);

    if (type == samp::EventType::IncomingRPC && id == samp::ServerMessage::event_id)
        return on_server_message(samp::ServerMessage(bit_stream));

    return true;
}
