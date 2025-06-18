#include "plugin/misc/features/message_hider.h"
#include "plugin/plugin.h"
#include <ctre.hpp>

std::unordered_map<std::string, std::vector<plugin::misc::features::message_hider::message_to_hide_t>>
plugin::misc::features::message_hider::messages = {
    { "hide_anticheat", {
        text_to_find { "Античит" },
        text_to_find { "[BOT DETECTOR]" }
    }},

    { "hide_punishments", {
        text_to_find { "Администратор ", ". Причина:" },
        text_to_find { "Администратор ", "установил <Player Kill> персонажу " },
        text_to_find { "Администратор ", "установил <Character Kill> персонажу " }
    }},

    { "hide_player_actions", {
        text_to_find { "[A] ", "нарисовал граффити. MysqlID: ", true },
        text_to_find { "[A] ", "установил описание: ", true },
        text_to_find { "[A] ", "установил описание авто: ", true },
        text_to_find { "[GBUY] ", "создал объявление ", true },
        text_to_find { "[A] ", "установил слухи: ", true },
        text_to_find { "[A] ", "установил действие: ", true },
        text_to_find { "[A] ", "перевёл деньги ", true },
        text_to_find { "[A] ", "передал деньги ", true }
    }},

    { "hide_complaints", { text_to_find { "[A] Жалоба от " } }},
    { "hide_questions", { text_to_find { "[A] Репорт от " } }},
    { "hide_admin_actions", { 0xAAAFAFAF }}
}; // plugin::misc::features::message_hider::messages

auto plugin::misc::features::message_hider::on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool {
    bool ends_with_ellipsis = message.text.ends_with(" ..") || message.text.ends_with(" ...");

    if (skip_next_message) {
        skip_next_message = ends_with_ellipsis;
        return false;
    }

    auto feature_configuration = (*configuration)["misc"]["message_hider"];
    bool hide_this_message = false;

    for (const auto& [ key, messages_to_hide ] : messages) {
        if (!feature_configuration[key])
            continue;

        for (const auto& message_to_hide : messages_to_hide) {
            if (std::holds_alternative<types::color>(message_to_hide)) {
                if (message.color == std::get<types::color>(message_to_hide))
                    return false;

                continue;
            }

            text_to_find text = std::get<text_to_find>(message_to_hide);

            if (!message.text.starts_with(text.start))
                continue;

            if (!text.continuation.has_value() || (!text.skip_nickname_after_start && message.text.contains(*text.continuation))) {
                hide_this_message = true;
                break;
            }
        
            static constexpr ctll::fixed_string skip_nickname_pattern = R"(^\[\S+\] .+[\[\]\d\.]+ (.*))";

            if (auto [ whole, continuation ] = ctre::match<skip_nickname_pattern>(message.text);
                whole && continuation.str().starts_with(*text.continuation))
            {
                hide_this_message = true;
                break;
            }
        }
    }

    if (!hide_this_message)
        return true;

    if (ends_with_ellipsis)
        skip_next_message = true;

    return false;
}

auto plugin::misc::features::message_hider::on_event(const samp::event_info& event) -> bool {
    bool use = (*configuration)["misc"]["message_hider"]["use"];

    if (use && event == samp::event_id::server_message && event == samp::event_type::incoming_rpc)
        return on_server_message(event.create<samp::event_id::server_message>());

    return true;
}
