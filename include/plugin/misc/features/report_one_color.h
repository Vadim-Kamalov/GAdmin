#ifndef GADMIN_PLUGIN_MISC_FEATURES_REPORT_ONE_COLOR_H
#define GADMIN_PLUGIN_MISC_FEATURES_REPORT_ONE_COLOR_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/server_message.h"

namespace plugin::misc::features {

class report_one_color : public feature {
private:
    bool change_next_message_color = false;
    bool on_server_message(const samp::event<samp::event_id::server_message>& event);
public:
    bool on_event(const samp::event_info& event) override;
}; // class report_one_color : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_REPORT_ONE_COLOR_H
