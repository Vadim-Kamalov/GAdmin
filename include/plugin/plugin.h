#ifndef GADMIN_PLUGIN_PLUGIN_H
#define GADMIN_PLUGIN_PLUGIN_H

#include "plugin/cheats/initializer.h"
#include "plugin/configuration.h"
#include "plugin/log.h"
#include "plugin/gui/gui.h"
#include "plugin/misc/misc.h"
#include "plugin/samp/network/event_handler.h"
#include <windows.h>
#include <fstream>
#include <winnt.h>

namespace plugin {

inline std::unique_ptr<samp::event_handler> event_handler;
inline std::unique_ptr<configuration_initializer> configuration;
inline std::unique_ptr<cheats::initializer> cheats_initializer;
inline std::unique_ptr<misc::initializer> misc_initializer;

class plugin_initializer final {
private:
    std::mutex log_mutex;
    std::ofstream log_file_stream;
    std::unique_ptr<gui_initializer> gui;

    bool plugin_working = true;

    auto on_samp_initialize() -> void;
    auto on_log_message(const log::type& type, const std::string_view& message) -> void;
    auto initialize_logging() -> void;
    auto initialize_event_handler() -> void;
    auto create_and_initialize_files() -> void;
    
    static auto on_terminate() noexcept -> void;
    static auto __stdcall on_unhandled_exception(EXCEPTION_POINTERS* exception_info) noexcept -> long;
public:
    auto unload() -> void;
    auto is_active() const -> bool;

    auto on_event(const samp::event_info& event) -> bool;
    auto can_initialize_render() const -> bool;
    auto on_render_initialize() -> void;
    auto on_frame() -> void;
    auto on_message(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool;
    auto main_loop() -> void;

    explicit plugin_initializer();
    ~plugin_initializer() noexcept;
}; // class plugin_initializer final

} // namespace plugin

#endif // GADMIN_PLUGIN_PLUGIN_H
