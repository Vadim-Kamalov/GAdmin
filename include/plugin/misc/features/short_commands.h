#ifndef GADMIN_PLUGIN_MISC_FEATURES_SHORT_COMMANDS_H
#define GADMIN_PLUGIN_MISC_FEATURES_SHORT_COMMANDS_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/send_command.h" // IWYU pragma: keep

namespace plugin::misc::features {

class short_commands : public feature {
private:
    auto on_send_command(const samp::out_event<samp::event_id::send_command>& event) const -> bool;
public:
    auto on_event(const samp::event_info& event) -> bool override;
}; // class short_commands : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_SHORT_COMMANDS_H
