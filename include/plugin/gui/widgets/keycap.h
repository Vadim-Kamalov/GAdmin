#ifndef GADMIN_PLUGIN_GUI_WIDGETS_KEYCAP_H
#define GADMIN_PLUGIN_GUI_WIDGETS_KEYCAP_H

#include <chrono>
#include <string>
#include <utility>
#include <unordered_map>
#include <imgui.h>
#include "plugin/types/color.h"

namespace plugin::gui::widgets {

class keycap {
private:
    std::string label;
    ImVec2 size;
    bool state;
    
    struct configuration_t {
        bool state;
        types::color color;
        std::chrono::steady_clock::time_point time;
    }; // struct configuration_t

    static inline std::unordered_map<std::string, configuration_t> pool;
public:
    void render() const;
    explicit keycap(const std::string_view& label, const ImVec2& size, bool state)
        : label(std::move(label)), size(std::move(size)), state(state) {}
}; // class keycap

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_KEYCAP_H
