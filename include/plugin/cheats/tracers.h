#ifndef GADMIN_PLUGIN_CHEATS_TRACERS_H
#define GADMIN_PLUGIN_CHEATS_TRACERS_H

#include "plugin/cheats/base.h"
#include "plugin/types/simple.h"
#include <chrono>
#include <deque>

namespace plugin::cheats {

class tracers : public basic_cheat {
private:
    struct tracer_information {
        bool miss = false;
        types::vector_3d origin;
        types::vector_3d target;
        std::chrono::steady_clock::time_point time;
    }; // struct tracer_information

    gui::hotkey hotkey;
    std::deque<tracer_information> current_tracers;

    void hotkey_callback(gui::hotkey& hotkey);
    bool on_bullet_synchronization(const samp::packet<samp::event_id::bullet_synchronization>& synchronization);
public:
    bool on_event(const samp::event_info& event) override;
    void render(types::not_null<gui_initializer*> child) override;
    void register_hotkeys(types::not_null<gui::hotkey_handler*> handler) override;

    explicit tracers();
}; // class tracers : public basic_cheat

} // namespace plugin::cheats

#endif // GADMIN_PLUGIN_CHEATS_TRACERS_H
