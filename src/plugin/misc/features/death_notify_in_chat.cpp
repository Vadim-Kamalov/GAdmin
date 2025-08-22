#include "plugin/misc/features/death_notify_in_chat.h"
#include "plugin/samp/core/chat.h"
#include "plugin/plugin.h"

auto plugin::misc::features::death_notify_in_chat::on_death_notification(const samp::event<samp::event_id::player_death_notification>& notification) const
    -> bool
{
    types::color color = (*configuration)["misc"]["death_notify_in_chat"]["color"];
    samp::chat::add_message(color, "[G] {}", notification.to_string());
    return true;
}

auto plugin::misc::features::death_notify_in_chat::on_event(const samp::event_info& event) -> bool {
    bool use = (*configuration)["misc"]["death_notify_in_chat"]["use"];

    if (use && event == samp::event_type::incoming_rpc && event == samp::event_id::player_death_notification)
        return on_death_notification(event.create<samp::event_id::player_death_notification>());

    return true;
}
