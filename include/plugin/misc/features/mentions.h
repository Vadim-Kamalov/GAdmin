#ifndef GADMIN_PLUGIN_MISC_FEATURES_MENTIONS_H
#define GADMIN_PLUGIN_MISC_FEATURES_MENTIONS_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/server_message.h"

namespace plugin::misc::features {

class mentions final : public feature {
private:
    auto is_user_mentioned(const std::string_view& possible_mention) const -> bool;
    auto on_server_message(const samp::event<samp::event_id::server_message>& message) const -> bool;
public:
    auto on_event(const samp::event_info& event) -> bool override;
}; // class mentions : public feature

} // namespace plugin::misc::features 

#endif // GADMIN_PLUGIN_MISC_FEATURES_MENTIONS_H
