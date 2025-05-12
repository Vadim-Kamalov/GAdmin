#ifndef GADMIN_PLUGIN_MISC_FEATURES_HIDE_ADDRESSES_H
#define GADMIN_PLUGIN_MISC_FEATURES_HIDE_ADDRESSES_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/server_message.h"
#include "plugin/samp/events/dialog.h"

namespace plugin::misc::features {

class hide_addresses : public feature {
private:
    std::optional<std::string> try_change_addresses(const std::string_view& input) const;
    bool is_ip_address(const std::string_view& input) const;

    bool on_server_message(const samp::event<samp::event_id::server_message>& message) const;
    bool on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) const;
public:
    bool on_event(const samp::event_info& event) override;
}; // class hide_addresses : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_HIDE_ADDRESSES_H
