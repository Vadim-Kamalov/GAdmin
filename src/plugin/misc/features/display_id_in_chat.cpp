#include "plugin/misc/features/display_id_in_chat.h"
#include "plugin/samp/core/player_pool.h"
#include "plugin/plugin.h"
#include "plugin/samp/core/user.h"

auto plugin::misc::features::display_id_in_chat::replace(const std::string& input, const std::string& target,
                                                         const std::string& replacement) -> std::string
{
    std::string result = "";
    std::size_t target_length = target.length();
    std::size_t pos = 0;

    while (pos < input.length()) {
        std::size_t found = input.find(target, pos);

        if (found == std::string::npos) {
            result += input.substr(pos);
            break;
        }

        bool has_bracket = false;
        std::size_t check_pos = found + target_length;

        while (check_pos < input.length() && std::isspace(input[check_pos]))
            check_pos++;

        if (check_pos < input.length() && input[check_pos] == '[')
            has_bracket = true;

        result += input.substr(pos, found - pos);

        if (!has_bracket) {
            result += replacement;
            pos = found + target_length;

            continue;
        }

        result += target;
        pos = found + target_length;
    }

    return result;
}

auto plugin::misc::features::display_id_in_chat::on_server_message(const samp::event<samp::event_id::server_message>& message) const
    -> bool
{
    std::string result = message.text;

    for (std::uint16_t id = 0; id <= SERVER_MAX_PLAYERS; ++id) {
        std::string nickname = "";

        if (id == samp::user::get_id())
            nickname = samp::user::get_name();
        else if (auto found_nickname = samp::player_pool::get_nickname(id))
            nickname = *found_nickname;
        
        if (nickname.empty())
            continue;

        std::replace(nickname.begin(), nickname.end(), '_', ' ');

        if (!result.contains(nickname))
            continue;

        result = replace(result, nickname, std::format("{}[{}]", nickname, id));
    }

    if (result != message.text)
        message.write_text(result);

    return true;
}

auto plugin::misc::features::display_id_in_chat::on_event(const samp::event_info& event) -> bool {
    bool use = (*configuration)["misc"]["display_id_in_chat"];

    if (use && event == samp::event_type::incoming_rpc && event == samp::event_id::server_message)
        return on_server_message(event.create<samp::event_id::server_message>());

    return true;
}
