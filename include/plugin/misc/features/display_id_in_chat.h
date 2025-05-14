#ifndef GADMIN_PLUGIN_MISC_FEATURES_DISPLAY_ID_IN_CHAT
#define GADMIN_PLUGIN_MISC_FEATURES_DISPLAY_ID_IN_CHAT

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/server_message.h"

namespace plugin::misc::features {

class display_id_in_chat : public feature {
private:
    bool on_server_message(const samp::event<samp::event_id::server_message>& message) const;
public:
    bool on_event(const samp::event_info& event) override;
}; // class display_id_in_chat : public feature

} // namespace plugin::misc::feature 

#endif // GADMIN_PLUGIN_MISC_FEATURES_DISPLAY_ID_IN_CHAT
