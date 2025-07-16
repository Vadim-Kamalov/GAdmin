#ifndef GADMIN_PLUGIN_GUI_WIDGETS_TEXT_BUTTON_H
#define GADMIN_PLUGIN_GUI_WIDGETS_TEXT_BUTTON_H

#include "plugin/gui/animation.h"
#include <chrono>
#include <string>
#include <unordered_map>

using namespace std::chrono_literals;

namespace plugin::gui::widgets {

class text_button final {
private:
    struct configuration_t final {
        animation::hover_info hover_info;
        float alpha = 0.00;
    }; // struct configuration_t final

    static inline std::unordered_map<std::string, configuration_t> pool;
    static constexpr std::chrono::milliseconds animation_duration = 300ms;
    static constexpr std::uint8_t line_height = 3;

    std::string label;
public:
    auto render() const -> bool;

    explicit text_button(const std::string_view& label);
}; // class text_button final

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_TEXT_BUTTON_H
