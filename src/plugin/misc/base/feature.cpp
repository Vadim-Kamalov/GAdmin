#include "plugin/misc/base/feature.h"

auto plugin::misc::feature::on_event(const samp::event_info& event) -> bool {
    return true;
}

auto plugin::misc::feature::main_loop() -> void {}
