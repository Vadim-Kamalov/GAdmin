#ifndef GADMIN_PLUGIN_MISC_FEATURES_DEATH_NOTIFY_IN_CHAT_H
#define GADMIN_PLUGIN_MISC_FEATURES_DEATH_NOTIFY_IN_CHAT_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/player_death_notification.h"

namespace plugin::misc::features {

class death_notify_in_chat final : public feature {
private:
    auto on_death_notification(const samp::event<samp::event_id::player_death_notification>& notification) const -> bool;
public:
    auto on_event(const samp::event_info& event) -> bool override;
}; // class death_notify_in_chat final : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_DEATH_NOTIFY_IN_CHAT_H
