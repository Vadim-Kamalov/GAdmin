#ifndef GADMIN_PLUGIN_GUI_WIDGETS_JOYSTICK_H
#define GADMIN_PLUGIN_GUI_WIDGETS_JOYSTICK_H

#include <chrono>
#include <imgui.h>

namespace plugin::gui::widgets {

class joystick {
private:
    static constexpr std::uint8_t radius = 37;
    static constexpr std::uint8_t dot_radius = 10;

    ImVec2 current, old;
    std::chrono::steady_clock::time_point time;
public:
    void update(std::uint16_t x, std::uint16_t y);
    void render() const;
}; // class joystick

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_JOYSTICK_H
