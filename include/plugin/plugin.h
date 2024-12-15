#ifndef GADMIN_PLUGIN_PLUGIN_H
#define GADMIN_PLUGIN_PLUGIN_H

#include "plugin/configuration.h"
#include "plugin/log.h"
#include "plugin/gui/gui.h"
#include "plugin/samp/network/event_handler.h"
#include <windows.h>
#include <fstream>

namespace plugin {

inline std::unique_ptr<samp::event_handler> event_handler;
inline std::unique_ptr<configuration_initializer> configuration;

class plugin_initializer {
private:
    std::mutex log_mutex;
    std::ofstream log_file_stream;
    std::unique_ptr<gui_initializer> gui;
    
    bool plugin_working = true;

    void on_samp_initialize();
    void on_log_message(const log::type& type, const std::string_view& message);

    void initialize_logging();
    void initialize_event_handler();
    void create_and_initialize_files();
public:
    constexpr void unload() { plugin_working = false; }
    constexpr bool active() const { return plugin_working; }

    bool on_event(const samp::event_type& type, std::uint8_t id, samp::bit_stream* stream);
    bool can_initialize_render() const;
    void on_render_initialize();
    void on_frame();
    bool on_message(unsigned int message, WPARAM wparam, LPARAM lparam);
    void main_loop();

    explicit plugin_initializer();
    ~plugin_initializer() noexcept;
}; // class plugin_initializer

} // namespace plugin

#endif // GADMIN_PLUGIN_PLUGIN_H
