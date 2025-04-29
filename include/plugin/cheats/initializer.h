#ifndef GADMIN_PLUGIN_CHEATS_LOADER_H
#define GADMIN_PLUGIN_CHEATS_LOADER_H

#include "plugin/cheats/base.h"
#include "plugin/gui/hotkey.h"
#include <deque>

namespace plugin::cheats {

class initializer {
private:
    types::not_null<gui_initializer*> gui;
    std::deque<cheat_t> cheats;
public:
    void main_loop();
    void render();

    void on_alogin_new_state(bool state);
    bool on_event(const samp::event_info& event);
    bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam);

    explicit initializer(types::not_null<gui_initializer*> gui);
}; // class initializer

} // namespace plugin::cheats

#endif // GADMIN_PLUGIN_CHEATS_LOADER_H
