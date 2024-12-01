#ifndef GADMIN_PLUGIN_GUI_BASE_WINDOW_H
#define GADMIN_PLUGIN_GUI_BASE_WINDOW_H

#include "plugin/samp/network/event_handler.h"
#include <memory>
#include <minwindef.h>

namespace plugin::gui {

class Window {
public:
    virtual ~Window() = default;
    virtual constexpr const char* get_id() const = 0;
    virtual void on_samp_initialize() {}
    virtual void render() = 0;
    virtual bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam) { return true; }
    virtual bool on_event(const samp::EventType& event, std::uint8_t id, samp::BitStream* bit_stream) { return true; }
}; // class Window

using WindowRef = std::shared_ptr<Window>;

} // namespace plugin::gui

#endif // GADMIN_PLUGIN_GUI_BASE_WINDOW_H
