#ifndef GADMIN_PLUGIN_PLUGIN_H
#define GADMIN_PLUGIN_PLUGIN_H

#include "plugin/log.h"
#include "plugin/gui/gui.h"
#include "plugin/samp/network/event_handler.h"
#include <windows.h>
#include <fstream>

namespace plugin {

inline std::unique_ptr<samp::EventHandler> event_handler;

class Plugin {
private:
    std::mutex log_mutex;
    std::ofstream log_file_stream;
    std::unique_ptr<GraphicalUserInterface> gui;
    
    bool plugin_working = true;

    void on_samp_initialize();
    void on_log_message(const log::Type& type, const std::string_view& message);
public:
    inline void unload() { plugin_working = false; }
    inline bool active() { return plugin_working; }

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
