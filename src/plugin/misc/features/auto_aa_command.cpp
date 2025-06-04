#include "plugin/misc/features/auto_aa_command.h"
#include "plugin/samp/core/input.h"
#include "plugin/server/user.h"
#include "plugin/server/spectator.h"
#include "plugin/plugin.h"

auto plugin::misc::features::auto_aa_command::on_send_chat(const samp::out_event<samp::event_id::send_chat>& chat) const
    -> bool
{
    if (server::user::is_on_alogin() && !server::spectator::is_active()) {
        samp::input::send_command("/aa {}", chat.text);
        return false;
    }

    return true;
}

auto plugin::misc::features::auto_aa_command::on_event(const samp::event_info& event) -> bool {
    bool use_feature = (*configuration)["misc"]["auto_aa_command"];

    if (use_feature && event == samp::event_type::outgoing_rpc && event == samp::event_id::send_chat)
        return on_send_chat(event.create<samp::event_id::send_chat, samp::event_type::outgoing_rpc>());

    return true;
}
