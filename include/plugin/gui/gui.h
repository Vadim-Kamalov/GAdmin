#ifndef GADMIN_PLUGIN_GUI_H
#define GADMIN_PLUGIN_GUI_H

#include "plugin/gui/base/window.h"
#include <minwindef.h>
#include <vector>

namespace plugin {

class GraphicalUserInterface {
private:
    std::vector<gui::WindowRef> registered_windows;

    bool cursor_active = true;
public:
    bool on_event(const samp::EventType& type, std::uint8_t id, samp::BitStream* bit_stream) const;
    bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam) const;
    
    void on_samp_initialize() const;
    void render() const;

    constexpr bool is_cursor_active() const noexcept { return cursor_active; }
    void enable_cursor();
    void disable_cursor();
    void switch_cursor();

    explicit GraphicalUserInterface();
}; // class GraphicalUserInterface

} // namespace plugin

#endif // GADMIN_PLUGIN_GUI_H
