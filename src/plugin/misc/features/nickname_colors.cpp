#include "plugin/misc/features/nickname_colors.h"
#include "plugin/common_utils.h"
#include "plugin/log.h"
#include "plugin/plugin.h"
#include <common/network.h>
#include <algorithm>
#include <ctre.hpp>

auto plugin::misc::features::nickname_colors::on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool {
    static constexpr ctll::fixed_string message_pattern = R"(^\[A\] (\S+)(\[\d+\].*))";
    
    if (entries.empty())
        return true;

    if (auto [ whole, nickname, other ] = ctre::search<message_pattern>(message.text);
        whole && message.color == 0xAA33AA33)
    {
        if (auto entry = std::find_if(entries.begin(), entries.end(), [nickname](const entry_t& entry) {
            return entry.nickname == nickname;
        }); entry != entries.end()) {
            types::color random_color = *common_utils::select_randomly(entry->colors.begin(), entry->colors.end());
            std::string color = std::format("{:06X}", random_color.cast<types::color_type::rgba>()).substr(0, 6);
            std::string new_nickname = std::format("{{{}}}{}{{33AA33}}", color, nickname.str());
            
            message.write_text(std::format("[A] {}{}", new_nickname, other.str()));
        }
    }

    return true;
}

auto plugin::misc::features::nickname_colors::append_entries(nlohmann::json& object) -> void {
    for (const auto& [ key, value ] : object.items()) {
        if (value.is_array()) {
            std::vector<types::color> colors;

            for (const auto& color : value) {
                std::string color_with_max_alpha = color.get<std::string>() + "FF";
                types::color raw_color = types::color::rgba(std::stoul(color_with_max_alpha, nullptr, 16));
                colors.push_back(raw_color);
            }

            entries.push_back({ key, colors });

            continue;
        }
        
        std::string color_with_max_alpha = value.get<std::string>() + "FF";
        types::color raw_color = types::color::rgba(std::stoul(color_with_max_alpha, nullptr, 16));

        entries.push_back({ key, { raw_color }});
    }
}

auto plugin::misc::features::nickname_colors::on_event(const samp::event_info& event) -> bool {
    bool use_feature = (*configuration)["misc"]["nickname_colors"];

    if (use_feature && event == samp::event_type::incoming_rpc && event == samp::event_id::server_message) 
        return on_server_message(event.create<samp::event_id::server_message>());

    return true;
}

plugin::misc::features::nickname_colors::nickname_colors() {
    downloader_thread = std::jthread([this](std::stop_token stop_token) {
        std::string nickname_colors = common::network::fetch_file_content(PROJECT_DATABASE "/nickname-colors.json", stop_token);

        if (nickname_colors.empty()) {
            log::error("failed to fetch [PROJECT_DATABASE \"/nickname-colors.json\"]: nickname_colors.empty() => true");
            return;
        }

        nlohmann::json json = nlohmann::json::parse(nickname_colors);

        append_entries(json["contributors"]);
        append_entries(json["sponsors"]);
    });
}

plugin::misc::features::nickname_colors::~nickname_colors() noexcept {
    if (downloader_thread.joinable()) {
        downloader_thread.request_stop();
        downloader_thread.join();
    }
}

auto plugin::misc::get_nickname_colors() noexcept -> std::deque<features::nickname_colors::entry_t>& {
    return features::nickname_colors::entries;
}
