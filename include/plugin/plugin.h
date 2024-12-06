#ifndef GADMIN_PLUGIN_PLUGIN_H
#define GADMIN_PLUGIN_PLUGIN_H

#include "plugin/configuration.h"
#include "plugin/log.h"
#include "plugin/gui/gui.h"
#include "plugin/samp/network/event_handler.h"
#include <windows.h>
#include <fstream>

namespace plugin {

inline std::unique_ptr<samp::EventHandler> event_handler;
inline std::unique_ptr<Configuration> configuration;

class Plugin {
private:
    std::mutex log_mutex;
    std::ofstream log_file_stream;
    std::unique_ptr<GraphicalUserInterface> gui;
    
    bool plugin_working = true;

    void on_samp_initialize();
    void on_log_message(const log::Type& type, const std::string_view& message);

    void initialize_logging();
    void initialize_event_handler();
    void create_and_initialize_files();
    void create_directories();
public:
    constexpr void unload() { plugin_working = false; }
    constexpr bool active() const { return plugin_working; }

    bool on_event(const samp::EventType& type, std::uint8_t id, samp::BitStream* bit_stream);
    bool can_initialize_render() const;
    void on_render_initialize();
    void on_frame();
    bool on_message(unsigned int message, WPARAM wparam, LPARAM lparam);
    void main_loop();

    explicit Plugin();
    ~Plugin();
}; // class Plugin

} // namespace plugin

#endif // GADMIN_PLUGIN_PLUGIN_H
