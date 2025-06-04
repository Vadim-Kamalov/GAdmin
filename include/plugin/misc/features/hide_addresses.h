#ifndef GADMIN_PLUGIN_MISC_FEATURES_HIDE_ADDRESSES_H
#define GADMIN_PLUGIN_MISC_FEATURES_HIDE_ADDRESSES_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/server_message.h"
#include "plugin/samp/events/dialog.h"

namespace plugin::misc::features {

class hide_addresses final : public feature {
private:
    auto try_change_addresses(const std::string_view& input) const -> std::optional<std::string>;
    auto is_ip_address(const std::string_view& input) const -> bool;

    auto on_server_message(const samp::event<samp::event_id::server_message>& message) const -> bool;
    auto on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) const -> bool;
public:
    auto on_event(const samp::event_info& event) -> bool override;
}; // class hide_addresses final : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_HIDE_ADDRESSES_H
