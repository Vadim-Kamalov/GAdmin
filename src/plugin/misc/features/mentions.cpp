#include "plugin/misc/features/mentions.h"
#include "plugin/gui/icon.h"
#include "plugin/gui/notify.h"
#include "plugin/string_utils.h"
#include "plugin/types/string_iterator.h"
#include "plugin/samp/core/audio.h"
#include "plugin/samp/core/user.h"
#include "plugin/types/color.h"
#include "plugin/plugin.h"
#include <algorithm>
#include <exception>
#include <ctre.hpp>

auto plugin::misc::features::mentions::is_user_mentioned(const std::string_view& possible_mention) const -> bool {
    if (!std::isalnum(possible_mention[0]) && possible_mention[0] != '@')
        return false;

    types::string_iterator iterator(possible_mention);

    if (possible_mention[0] == '@')
        iterator.consume();
    
    if (!iterator.current().has_value())
        return false;

    if (std::isdigit(*iterator.current())) {
        try {
            if (std::stoul(iterator.collect(::isdigit)) == samp::user::get_id()) {
                return true;
            }
        } catch (const std::exception& e) {
            log::warn("std::exception after std::stoul (in mentions::is_user_mentioned): e.what() => \"{}\"",
                      e.what());
        }
    } else {
        std::string text = iterator.collect([](unsigned char c) { return std::isalnum(c) || c == '_'; });

        std::transform(text.begin(), text.end(), text.begin(), ::tolower);

        if (text == "all")
            return true;
        
        std::string user_nickname = (*configuration)["user"]["nickname"];
        
        std::transform(user_nickname.begin(), user_nickname.end(), user_nickname.begin(), ::tolower);
        
        return user_nickname == text;
    }

    return false;
}

auto plugin::misc::features::mentions::on_server_message(const samp::event<samp::event_id::server_message>& message) const
    -> bool
{
    static constexpr ctll::fixed_string pattern = R"(^\[A\d\] (\S+)\[(\d+)\]: (\S+))";

    std::string clean_text = string_utils::remove_samp_colors(message.text);

    if (auto [ whole, sender_nickname, sender_id, possible_mention ] = ctre::search<pattern>(clean_text); whole) {
        if (samp::user::get_id() == std::stoul(sender_id.str()) || !is_user_mentioned(possible_mention.str()))
            return true;

        auto feature_configuration = (*configuration)["misc"]["mentions"];
        types::color changed_color = feature_configuration["color"];

        if (feature_configuration["sound_notify"])
            samp::audio::play_sound(samp::audio::sound_id::bell);
    
        std::string notification_description = std::format("Администратор {} только что упомянул вас в /a чате.", sender_nickname.str());

        gui::notify::send(gui::notification("Вас упомянули в чате!", notification_description, ICON_USER02));

        message.write(clean_text, changed_color);
    }

    return true;
}

auto plugin::misc::features::mentions::on_event(const samp::event_info& event) -> bool {
    bool use = (*configuration)["misc"]["mentions"]["use"];

    if (use && event == samp::event_type::incoming_rpc && event == samp::event_id::server_message)
        return on_server_message(event.create<samp::event_id::server_message>());

    return true;
}
