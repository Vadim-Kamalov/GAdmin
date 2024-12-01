#ifndef GADMIN_PLUGIN_GUI_H
#define GADMIN_PLUGIN_GUI_H

#include "plugin/utils.h"
#include "plugin/gui/base/window.h"
#include <minwindef.h>
#include <vector>

namespace plugin {

class GraphicalUserInterface {
    std::vector<utils::not_null<gui::WindowRef>> windows;
public:
    bool on_event(const samp::EventType& type, std::uint8_t id, samp::BitStream* bit_stream) const;
    bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam) const;
    
    void on_samp_initialize() const;
    void render() const;

    explicit GraphicalUserInterface();
}; // class GraphicalUserInterface

} // namespace plugin

#endif // GADMIN_PLUGIN_GUI_H
