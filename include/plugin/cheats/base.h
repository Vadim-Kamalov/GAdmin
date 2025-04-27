#ifndef GADMIN_PLUGIN_CHEATS_BASE_H
#define GADMIN_PLUGIN_CHEATS_BASE_H

#include "plugin/gui/hotkey.h"
#include "plugin/samp/events/event.h"
#include <memory>

namespace plugin::cheats {

class basic_cheat {
public:
    virtual ~basic_cheat() = default;

    virtual void register_hotkeys(types::not_null<gui::hotkey_handler*> handler) {}
    virtual void render(types::not_null<gui_initializer*> child) {}
    
    virtual void main_loop() {}
    
    virtual bool on_event(const samp::event_info& event) { return true; }
    virtual bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam) { return true; }
}; // class basic_cheat

using cheat_t = std::unique_ptr<basic_cheat>;

} // namespace plugin::cheats

#endif // GADMIN_PLUGIN_CHEATS_BASE_H
