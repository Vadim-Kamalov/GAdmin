#ifndef GADMIN_PLUGIN_GUI_WIDGETS_BUTTON_H
#define GADMIN_PLUGIN_GUI_WIDGETS_BUTTON_H

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
        float radius = 0;
        std::uint8_t hovered_alpha = 0;
        std::chrono::steady_clock::time_point time[2], hovered_time;
        bool hovered_state_current = false, hovered_state_before = false;
        std::optional<ImVec2> pos;
    }; // struct configuration_t
private:
    std::array<std::chrono::milliseconds, 3> durations = { 200ms, 400ms, 300ms };

    std::string label;
    ImVec2 size;
    ImDrawFlags draw_flags = ImDrawFlags_RoundCornersAll;

    static inline std::unordered_map<std::string_view, configuration_t> pool;
   
    std::string get_text_before_hashtag() const;
    void register_in_pool() const;
public:
    inline button& with_draw_flags(ImDrawFlags new_draw_flags) noexcept;
    inline button& with_durations(const std::array<std::chrono::milliseconds, 3>& durations) noexcept;

    bool render();

    explicit button(const std::string_view& label);
    explicit button(const std::string_view& label, const ImVec2& size)
        : label(std::move(label)), size(std::move(size)) { register_in_pool(); }
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
