#include "plugin/cheats/initializer.h"
#include "plugin/cheats/airbreak.h"
#include "plugin/gui/gui.h"

plugin::cheats::initializer::initializer(types::not_null<gui_initializer*> gui) : gui(gui) {
    cheats.push_back(std::make_unique<airbreak>());

    for (const auto& cheat : cheats)
        cheat->register_hotkeys(gui->hotkey_handler.get());
}

void
plugin::cheats::initializer::main_loop() {
    for (const auto& cheat : cheats)
        cheat->main_loop();
}

void
plugin::cheats::initializer::render() {
    for (const auto& cheat : cheats)
        cheat->render(gui);
}

bool
plugin::cheats::initializer::on_event(const samp::event_info& event) {
    for (const auto& cheat : cheats) {
        event.stream->reset_read_pointer();
        if (!cheat->on_event(event))
            return false;
    }

    return true;
}

bool
plugin::cheats::initializer::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) {
    for (const auto& cheat : cheats)
        if (!cheat->on_event(message, wparam, lparam))
            return false;
    
    return true;
}
