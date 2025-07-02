#include "plugin/misc/base/feature.h"

auto plugin::misc::feature::on_event(const samp::event_info&) -> bool {
    return true;
}

auto plugin::misc::feature::on_event(unsigned int, WPARAM, LPARAM) -> bool {
    return true;
}

auto plugin::misc::feature::on_alogin_new_state(bool) -> void {}
auto plugin::misc::feature::main_loop() -> void {}
auto plugin::misc::feature::render(types::not_null<gui_initializer*>) -> void {}
auto plugin::misc::feature::on_samp_initialize() -> void {}
