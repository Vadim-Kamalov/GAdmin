#ifndef GADMIN_PLUGIN_PLUGIN_H
#define GADMIN_PLUGIN_PLUGIN_H

#include "plugin/samp/network/event_handler.h"

#include <windows.h>

namespace plugin {

class Plugin {
public:
    static samp::EventHandler event_handler;
    
    std::string last_message = "";

    bool on_event(const samp::EventType& type, std::uint8_t id, samp::BitStream* bit_stream);
    void on_render_initialize();
    void on_frame();
    bool on_message(unsigned int message, WPARAM wparam, LPARAM lparam);
    void main_loop();

    explicit Plugin();
    ~Plugin();
}; // class Plugin

} // namespace plugin

#endif // GADMIN_PLUGIN_PLUGIN_H
