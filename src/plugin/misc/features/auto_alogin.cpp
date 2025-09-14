#include "plugin/misc/features/auto_alogin.h"
#include "plugin/samp/events/synchronization.h" // IWYU pragma: keep
#include "plugin/samp/core/input.h"
#include "plugin/plugin.h"

auto plugin::misc::features::auto_alogin::on_event(const samp::event_info& event) -> bool {
    if (!done && event == samp::event_id::player_synchronization && event == samp::event_type::outgoing_packet) {
        if ((*configuration)["misc"]["auto_alogin"])
            samp::input::send_command("/alogin");

        done = true;
    }

    return true;
}
