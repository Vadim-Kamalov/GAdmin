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
    using frame_renderer_t = std::function<void(const std::string_view& label, std::any& payload)>;

    struct entry_t final {
        std::string label;
        std::any payload;
    }; // struct entry_t final
private:
    static constexpr std::chrono::milliseconds fade_in_duration = 200ms;
    static constexpr std::chrono::milliseconds fade_out_duration = 400ms;
    static constexpr std::chrono::milliseconds fade_in_out_duration = fade_in_duration + fade_out_duration;
    
    static constexpr float title_font_size = 24;
    static constexpr float child_default_width = 180;
    static constexpr float switch_button_default_height = 30;

    static constexpr float child_width_percent =
        (child_default_width * 100.0f) / initializer::default_window_size.x; ///< 25%

    static constexpr float switch_button_percent =
        (switch_button_default_height * 100.0f) / initializer::default_window_size.y; ///< 6%

    frame_renderer_t frame_renderer = [](const auto&, auto&) {};
    std::vector<entry_t> entries;
    std::string label;
   
    std::size_t future_entry_index = 0;
    std::size_t current_entry_index = 0;

    float frame_alpha = 1.00;
    std::chrono::steady_clock::time_point time_clicked;
public:
    auto add_entry(const std::string_view& label, const std::any& payload) -> void;
    auto set_frame_renderer(frame_renderer_t new_frame_renderer) -> void;
    
    auto render_menu(types::not_null<initializer*> child) -> void;
    auto render_current_frame(types::not_null<initializer*> child) -> void;

    explicit submenu(const std::string_view& label)
        : label(std::move(label)) {}
}; // class submenu final

} // namespace plugin::gui::windows::main::widgets

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_SUBMENU_H
