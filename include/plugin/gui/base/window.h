#ifndef GADMIN_PLUGIN_GUI_BASE_WINDOW_H
#define GADMIN_PLUGIN_GUI_BASE_WINDOW_H

#include "plugin/samp/network/event_handler.h"
#include "plugin/log.h"
#include <memory>
#include <minwindef.h>

namespace plugin::gui {

class window {
private:
    bool rendering = true;
public:
    virtual ~window() = default;
    
    virtual constexpr const char* get_id() const = 0;
    virtual constexpr bool render_on_game_paused() const { return false; }
    
    virtual void render() = 0;
    
    virtual bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam) { return true; }
    virtual bool on_event(const samp::event_type& event, std::uint8_t id, samp::bit_stream* stream) { return true; }
    virtual void on_samp_initialize() {}

    constexpr bool can_render() const noexcept { return rendering; }
    constexpr void stop_render() noexcept { log::error("plugin::gui::{}::stop_render()", get_id()); rendering = false; }
}; // class Window

using window_ptr = std::unique_ptr<window>;

} // namespace plugin::gui

#endif // GADMIN_PLUGIN_GUI_BASE_WINDOW_H
