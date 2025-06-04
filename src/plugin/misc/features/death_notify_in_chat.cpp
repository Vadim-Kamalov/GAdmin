#include "plugin/misc/features/death_notify_in_chat.h"
#include "plugin/samp/core/player_pool.h"
#include "plugin/samp/core/chat.h"
#include "plugin/plugin.h"

auto plugin::misc::features::death_notify_in_chat::on_death_notification(const samp::event<samp::event_id::player_death_notification>& notification) const
    -> bool
{
    auto killed_nickname = samp::player_pool::get_nickname(notification.killed_id);

    if (!killed_nickname)
        return true;

    std::string message;
    std::string reason = notification.get_reason();
    types::color color = (*configuration)["misc"]["death_notify_in_chat"]["color"];

    if (notification.killer_id != notification.id_none) {
        auto killer_nickname = samp::player_pool::get_nickname(notification.killer_id);

        if (!killer_nickname)
            return true;
        
        message = std::format("{}[{}] убил {}[{}] с помощью {}.",
                              *killer_nickname, notification.killer_id,
                              *killed_nickname, notification.killed_id,
                              reason);
    } else
        message = std::format("{}[{}] погиб от {}.", *killed_nickname, notification.killed_id, reason);

    samp::chat::add_message(color, "[G] {}", message);

    return true;
}

auto plugin::misc::features::death_notify_in_chat::on_event(const samp::event_info& event) -> bool {
    bool use = (*configuration)["misc"]["death_notify_in_chat"]["use"];

    if (use && event == samp::event_type::incoming_rpc && event == samp::event_id::player_death_notification)
        return on_death_notification(event.create<samp::event_id::player_death_notification>());

    return true;
}
