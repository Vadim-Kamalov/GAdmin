#ifndef GADMIN_PLUGIN_GUI_WIDGETS_HINT_H
#define GADMIN_PLUGIN_GUI_WIDGETS_HINT_H

#include <imgui.h>
#include <string>
#include <chrono>
#include <functional>
#include <unordered_map>

using namespace std::chrono_literals;

namespace plugin::gui::widgets {

class hint {
public:
    using condition_t = std::function<bool()>;
    using renderer_t = std::function<void()>;
private:
    std::string label;

    renderer_t renderer = std::bind(&hint::default_renderer, this);
    condition_t condition = []{ return ImGui::IsItemHovered(); };
    
    std::chrono::milliseconds show_hide_duration = 200ms;
    std::uint32_t color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_FrameBg]);

    std::string get_text_before_hashtag() const;
    void default_renderer() const;
    void render_hint(float alpha) const;
private:
    struct configuration {
        float width;
        bool opened;
        std::chrono::steady_clock::time_point time;
    }; // struct configuration
    
    static inline std::unordered_map<std::string_view, configuration> pool;
public:
    inline hint& with_condition(condition_t new_condition) noexcept;
    inline hint& with_show_hide_duration(std::chrono::milliseconds duration) noexcept;
    inline hint& with_renderer(renderer_t new_renderer) noexcept;

    void render();

    explicit hint(const std::string_view& label)
        : label(std::move(label)) {}

    explicit hint(const std::string_view& label, std::uint32_t color)
        : label(std::move(label)), color(color) {}
}; // class hint

} // namespace plugin::gui::widgets

inline plugin::gui::widgets::hint&
plugin::gui::widgets::hint::with_condition(condition_t new_condition) noexcept {
    condition = new_condition;
    return *this;
}

inline plugin::gui::widgets::hint&
plugin::gui::widgets::hint::with_show_hide_duration(std::chrono::milliseconds duration) noexcept {
    show_hide_duration = duration;
    return *this;
}

inline plugin::gui::widgets::hint&
plugin::gui::widgets::hint::with_renderer(renderer_t new_renderer) noexcept {
    renderer = new_renderer;
    return *this;
}

#endif // GADMIN_PLUGIN_GUI_WIDGETS_HINT_H
