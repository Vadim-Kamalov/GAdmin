#ifndef GADMIN_PLUGIN_PLUGIN_H
#define GADMIN_PLUGIN_PLUGIN_H

#include "plugin/samp/network/event_handler.h"
#include <windows.h>
#include <fstream>

namespace plugin {

class Plugin {
private:
    std::mutex log_mutex;
    std::ofstream log_file_stream;
public:
    static samp::EventHandler event_handler;
    
    std::string last_message = "";

    void on_log_message(const std::string_view& message);
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
