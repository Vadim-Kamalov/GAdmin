#include "plugin/misc/features/display_id_in_chat.h"
#include "plugin/samp/core/player_pool.h"
#include "plugin/types/u8regex.h"
#include "plugin/plugin.h"

auto plugin::misc::features::display_id_in_chat::on_server_message(const samp::event<samp::event_id::server_message>& message) const
    -> bool
{
    static constexpr ctll::fixed_string basic_pattern = "^\\w+.* ";
    static constexpr ctll::fixed_string ic_chat_pattern = "^\\w+.* говорит:";
    static constexpr ctll::fixed_string capture_pattern = "^([\\w ]+) (.*)";

    if ((ctre::search<basic_pattern>(message.text) && message.color == 0xFF8054E7) ||
        types::u8regex::search<ic_chat_pattern>(message.text))
    {
        auto [ whole, nickname_match, other ] = ctre::search<capture_pattern>(message.text);

        if (!whole)
            return true;
        
        std::string nickname = nickname_match.str();
        
        std::replace(nickname.begin(), nickname.end(), ' ', '_');
        
        auto possible_id = samp::player_pool::get_id(nickname);

        if (!possible_id)
            return true;

        message.write_text(std::format("{}[{}] {}", nickname_match.str(), *possible_id, other.str()));
    }

    return true;
}

auto plugin::misc::features::display_id_in_chat::on_event(const samp::event_info& event) -> bool {
    bool use = (*configuration)["misc"]["display_id_in_chat"];

    if (use && event == samp::event_type::incoming_rpc && event == samp::event_id::server_message)
        return on_server_message(event.create<samp::event_id::server_message>());

    return true;
}
