#include "plugin/misc/misc.h"
#include "plugin/log.h"
#include "plugin/misc/features/auto_login.h"
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

    log::info("misc::initializer initialized");
}
