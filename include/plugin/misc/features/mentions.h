#ifndef GADMIN_PLUGIN_MISC_FEATURES_MENTIONS_H
#define GADMIN_PLUGIN_MISC_FEATURES_MENTIONS_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/server_message.h"

namespace plugin::misc::features {

class mentions : public feature {
private:
    bool is_user_mentioned(const std::string_view& possible_mention) const;
    bool on_server_message(const samp::event<samp::event_id::server_message>& message) const;
public:
    bool on_event(const samp::event_info& event) override;
}; // class mentions : public feature

} // namespace plugin::misc::features 

#endif // GADMIN_PLUGIN_MISC_FEATURES_MENTIONS_H
