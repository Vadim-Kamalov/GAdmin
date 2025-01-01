#ifndef GADMIN_PLUGIN_GUI_WIDGETS_JOYSTICK_H
#define GADMIN_PLUGIN_GUI_WIDGETS_JOYSTICK_H

#include <chrono>
#include <imgui.h>

namespace plugin::gui::widgets {

class joystick {
public:
    ImVec2 current, old;
    std::chrono::steady_clock::time_point time;
}; // class joystick

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_JOYSTICK_H
