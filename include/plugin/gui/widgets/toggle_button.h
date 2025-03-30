#ifndef GADMIN_PLUGIN_GUI_WIDGETS_TOGGLE_BUTTON_H
#define GADMIN_PLUGIN_GUI_WIDGETS_TOGGLE_BUTTON_H

#include "plugin/types/color.h"
#include "plugin/types/setter.h"
#include <imgui.h>
#include <chrono>
#include <unordered_map>

using namespace std::chrono_literals;

namespace plugin::gui::widgets {

class toggle_button {
private:
    struct configuration_t {
        std::chrono::steady_clock::time_point time;
        types::color color;
        float pos_x;
    }; // struct configuration_t
    
    static inline std::unordered_map<std::string, configuration_t> pool;

    std::string label;
    types::setter<bool> state;
public:
    bool render();

    explicit toggle_button(const std::string_view& label, bool& state)
        : label(std::move(label)), state(state) {}

    explicit toggle_button(const std::string_view& label, const types::setter<bool>& state)
        : label(std::move(label)), state(std::move(state)) {}
private:
    static constexpr float radius = 6;
    static constexpr ImVec2 size = { 40, 20 };
    static constexpr std::chrono::milliseconds duration = 300ms;
}; // class toggle_button

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_TOGGLE_BUTTON_H
