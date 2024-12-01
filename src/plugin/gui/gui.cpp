#include "plugin/gui/gui.h"
#include "plugin/gui/windows/main.h"
#include <windows.h>

bool
plugin::GraphicalUserInterface::on_event(const samp::EventType& type, std::uint8_t id, samp::BitStream* bit_stream) const {
    for (const auto& window : windows) {
        bit_stream->reset_read_pointer();
        if (!window->on_event(type, id, bit_stream))
            return false;
    }

    return true;
}

bool
plugin::GraphicalUserInterface::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) const {
    for (const auto& window : windows)
        if (!window->on_event(message, wparam, lparam))
            return false;

    return true;
}

void
plugin::GraphicalUserInterface::on_samp_initialize() const {
    for (const auto& window : windows)
        window->on_samp_initialize();
}

void
plugin::GraphicalUserInterface::render() const {
    for (const auto& window : windows)
        window->render();
}

plugin::GraphicalUserInterface::GraphicalUserInterface() {
    using namespace gui;

    windows = { windows::main() };
}
