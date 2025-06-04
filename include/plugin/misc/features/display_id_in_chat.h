#ifndef GADMIN_PLUGIN_MISC_FEATURES_DISPLAY_ID_IN_CHAT
#define GADMIN_PLUGIN_MISC_FEATURES_DISPLAY_ID_IN_CHAT

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/server_message.h"

namespace plugin::misc::features {

class display_id_in_chat final : public feature {
private:
    auto on_server_message(const samp::event<samp::event_id::server_message>& message) const -> bool;
public:
    auto on_event(const samp::event_info& event) -> bool override;
}; // class display_id_in_chat final : public feature

} // namespace plugin::misc::feature 

#endif // GADMIN_PLUGIN_MISC_FEATURES_DISPLAY_ID_IN_CHAT
