#include "plugin/gui/base/window.h"
#include "plugin/log.h"

auto plugin::gui::window::on_event(unsigned int, WPARAM, LPARAM) -> bool {
    return true;
}

auto plugin::gui::window::on_event(const samp::event_info&) -> bool {
    return true;
}

auto plugin::gui::window::stop_render() noexcept -> void {
    log::error("cannot render \"{}\" window", get_id());
    rendering = false;
}

plugin::gui::window::window(types::not_null<gui_initializer*> child) : child(child) {
    log::info("window \"{}\" initialized", get_id());
}
