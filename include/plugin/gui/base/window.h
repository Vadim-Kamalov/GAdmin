#ifndef GADMIN_PLUGIN_GUI_BASE_WINDOW_H
#define GADMIN_PLUGIN_GUI_BASE_WINDOW_H

#include "plugin/samp/network/event_handler.h"
#include "plugin/types/simple.h"
#include <memory>
#include <minwindef.h>

namespace plugin::gui {

class window {
private:
    bool rendering = true;
public:
    virtual ~window() = default;
    
    virtual constexpr types::zstring_t get_id() const = 0;
    virtual constexpr bool render_on_game_paused() const;
    
    virtual void render() = 0;
    
    virtual bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam);
    virtual bool on_event(const samp::event_type& event, std::uint8_t id, samp::bit_stream* stream);
    virtual void on_samp_initialize() {}

    constexpr bool can_render() const;
    void stop_render() noexcept;
}; // class window

using window_ptr_t = std::unique_ptr<window>;

} // namespace plugin::gui

constexpr bool
plugin::gui::window::render_on_game_paused() const {
    return false;
}

constexpr bool
plugin::gui::window::can_render() const {
    return rendering;
}

#endif // GADMIN_PLUGIN_GUI_BASE_WINDOW_H
