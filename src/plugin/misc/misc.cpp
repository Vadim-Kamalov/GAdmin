#include "plugin/misc/misc.h"
#include "plugin/misc/features/auto_aa_command.h"
#include "plugin/misc/features/auto_login.h"
#include "plugin/misc/features/death_notify_in_chat.h"
#include "plugin/misc/features/display_id_in_chat.h"
#include "plugin/misc/features/hide_addresses.h"
#include "plugin/misc/features/mentions.h"
#include "plugin/misc/features/nickname_colors.h"
#include "plugin/misc/features/report_one_color.h"
#include "plugin/log.h"
#include "plugin/misc/features/short_commands.h"
#include <memory>

bool
plugin::misc::initializer::on_event(const samp::event_info& event) {
    for (const auto& feature : features) {
        event.stream->reset_read_pointer();
        if (!feature->on_event(event))
            return false;
    }

    return true;
}

plugin::misc::initializer::initializer() {
    features.push_back(std::make_unique<features::auto_login>());
    features.push_back(std::make_unique<features::nickname_colors>());
    features.push_back(std::make_unique<features::auto_aa_command>());
    features.push_back(std::make_unique<features::hide_addresses>());
    features.push_back(std::make_unique<features::display_id_in_chat>());
    features.push_back(std::make_unique<features::mentions>());
    features.push_back(std::make_unique<features::report_one_color>());
    features.push_back(std::make_unique<features::death_notify_in_chat>());
    features.push_back(std::make_unique<features::short_commands>());

    log::info("misc::initializer initialized");
}
