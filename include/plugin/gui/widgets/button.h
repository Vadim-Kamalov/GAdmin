#ifndef GADMIN_PLUGIN_GUI_WIDGETS_BUTTON_H
#define GADMIN_PLUGIN_GUI_WIDGETS_BUTTON_H

#include "plugin/gui/animation.h"
#include <optional>
#include <string>
#include <utility>
#include <unordered_map>
#include <imgui.h>
#include <chrono>

using namespace std::chrono_literals;

namespace plugin::gui::widgets {

class button {
private:
    struct configuration_t {
        animation::hover_info hovered;
        std::uint8_t border_alpha = 0;
        float alpha = 0, radius = 0;
        std::optional<ImVec2> click_position;
        std::chrono::steady_clock::time_point click_time;
    }; // struct configuration_t
private:
    std::array<std::chrono::milliseconds, 3> durations = { 200ms, 400ms, 300ms };

    std::string id;

    ImVec2 size;
    ImDrawFlags draw_flags = ImDrawFlags_RoundCornersAll;

    static inline std::unordered_map<std::string, configuration_t> pool;
   
    void register_in_pool() const;
public:
    std::string label;

    inline button& with_draw_flags(ImDrawFlags new_draw_flags) noexcept;
    inline button& with_durations(const std::array<std::chrono::milliseconds, 3>& durations) noexcept;

    bool render();

    explicit button(const std::string_view& label);

    explicit button(const std::string_view& label, const std::string_view& id, const ImVec2& size)
        : label(std::move(label)), size(std::move(size)), id(std::move(id)) { register_in_pool(); }

    explicit button(const std::string_view& label, const ImVec2& size)
        : label(std::move(label)), size(std::move(size)), id(std::move(label)) { register_in_pool(); }

    button() = default;
}; // class button

} // namespace plugin::gui::widgets

inline plugin::gui::widgets::button&
plugin::gui::widgets::button::with_draw_flags(ImDrawFlags new_draw_flags) noexcept {
    draw_flags = new_draw_flags;
    return *this;
}

inline plugin::gui::widgets::button&
plugin::gui::widgets::button::with_durations(const std::array<std::chrono::milliseconds, 3>& new_durations) noexcept {
    durations = std::move(new_durations);
    return *this;
}

#endif // GADMIN_PLUGIN_GUI_WIDGETS_BUTTON_H
