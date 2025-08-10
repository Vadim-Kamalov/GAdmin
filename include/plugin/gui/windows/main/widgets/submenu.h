#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_SUBMENU_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_SUBMENU_H

#include "plugin/types/not_null.h"
#include "plugin/gui/windows/main/initializer.h"
#include <string>
#include <any>
#include <vector>
#include <functional>
#include <chrono>

using namespace std::chrono_literals;

namespace plugin::gui::windows::main::widgets {

class submenu final {
public:
    using frame_renderer_t = std::function<void(std::string& label, std::any& payload)>;
    using on_entry_destroy_callback_t = std::function<void(std::size_t index)>;
    using add_callback_t = std::function<void()>;
private:
    static constexpr std::chrono::milliseconds fade_in_duration = 150ms;
    static constexpr std::chrono::milliseconds fade_out_duration = 300ms;
    static constexpr std::chrono::milliseconds fade_in_out_duration = fade_in_duration + fade_out_duration;
    static constexpr std::chrono::milliseconds entry_animation_duration = fade_in_duration;
    
    static constexpr float title_font_size = 24;
    static constexpr float empty_placeholder_font_size = 18;
    static constexpr float child_default_width = 180;
    static constexpr float switch_button_default_height = 30;

    static constexpr float child_width_percent =
        (child_default_width * 100.0f) / initializer::default_window_size.x; ///< 25%

    static constexpr float switch_button_percent =
        (switch_button_default_height * 100.0f) / initializer::default_window_size.y; ///< 6%
    
    struct entry_t final {
        std::string label;
        std::any payload;
        std::chrono::steady_clock::time_point animation_time;
        float alpha = 1.00;
        bool hiding = false;
    }; // struct entry_t final

    frame_renderer_t frame_renderer = [](auto&, auto&) {};
    std::optional<on_entry_destroy_callback_t> on_entry_destroy_callback;
    std::optional<add_callback_t> add_callback;

    std::vector<entry_t> entries;
    std::string label;
    types::zstring_t selected_empty_placeholder;
   
    std::size_t future_entry_index = 0;
    std::size_t current_entry_index = 0;

    float frame_alpha = 1.00;
    std::chrono::steady_clock::time_point time_clicked;

    auto get_next_available_entry_index() const -> std::size_t;
    auto render_entry(std::size_t index, entry_t& entry, const ImVec2& size) -> void;
public:
    auto get_current_entry_index() const -> std::size_t;
    auto add_entry(const std::string_view& label, const std::any& payload) -> void;
    auto add_entry_animated(const std::string_view& label, const std::any& payload) -> void;
    auto remove_current_entry_animated() -> void;

    auto set_on_entry_destroyed_callback(on_entry_destroy_callback_t new_callback) -> void;
    auto set_add_callback(add_callback_t new_callback) -> void;
    auto set_frame_renderer(frame_renderer_t new_frame_renderer) -> void;
    
    auto render_menu(types::not_null<initializer*> child) -> void;
    auto render_current_frame(types::not_null<initializer*> child) -> void;

    explicit submenu(const std::string_view& label);
}; // class submenu final

} // namespace plugin::gui::windows::main::widgets

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_SUBMENU_H
