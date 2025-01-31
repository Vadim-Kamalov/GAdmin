#include "plugin/gui/base/window.h"
#include "plugin/log.h"

bool
plugin::gui::window::on_event(unsigned int, WPARAM, LPARAM) {
    return true;
}

bool
plugin::gui::window::on_event(const samp::event_type&, std::uint8_t, samp::bit_stream*) {
    return true;
}

void
plugin::gui::window::stop_render() noexcept {
    log::error("plugin::gui::{}::stop_render()", get_id());
    rendering = false;
}
