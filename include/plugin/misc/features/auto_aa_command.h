#ifndef GADMIN_PLUGIN_MISC_FEATURES_AUTO_AA_COMMAND
#define GADMIN_PLUGIN_MISC_FEATURES_AUTO_AA_COMMAND

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/send_chat.h" // IWYU pragma: keep

namespace plugin::misc::features {

class auto_aa_command final : public feature {
private:
    auto on_send_chat(const samp::out_event<samp::event_id::send_chat>& chat) const -> bool;
public:
    auto on_event(const samp::event_info& event) -> bool override;
}; // class auto_aa_command final : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_AUTO_AA_COMMAND
