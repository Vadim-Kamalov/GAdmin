#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_FRAME_SWITCHER_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_FRAME_SWITCHER_H

#include "plugin/gui/animation.h"
#include "plugin/gui/windows/main/frames/frames.h"
#include "plugin/gui/windows/main/widgets/frame_selector.h"
#include "plugin/types/color.h"
#include <chrono>

using namespace std::chrono_literals;

namespace plugin::gui::windows::main::widgets {

class frame_switcher final {
private:
    static constexpr float button_default_height = 30;
    static constexpr float button_height_percent =
        (button_default_height * 100.0f) / initializer::default_window_size.y; ///< ~6.6

    static constexpr std::chrono::milliseconds click_animation_duration = 200ms;
    static constexpr std::chrono::milliseconds hover_animation_duration = 400ms;
    static constexpr float icon_font_size = 24;
    static constexpr float text_font_size = 18;

    types::not_null<frame_selector*> child;
    types::color current_color;
    std::chrono::steady_clock::time_point time_clicked;
    animation::hover_info hover_info;
   
    ImFont* icon_font = nullptr;
    ImFont* bold_font = nullptr;
    ImVec2 button_size;
    frame switch_frame;

    auto update_button_size() -> void;
    auto update_current_color() -> void;
    auto render_button() -> void;
public:
    auto render() -> void;

    static auto get_from_pool(types::not_null<frame_selector*> child, const frame& switch_frame)
        noexcept -> std::unique_ptr<frame_switcher>&;

    explicit frame_switcher(types::not_null<frame_selector*> frame_selector, const frame& switch_frame)
        : child(frame_selector),
          switch_frame(switch_frame),
          icon_font(frame_selector->child->child->fonts->icon),
          bold_font(frame_selector->child->child->fonts->bold) {}
}; // class frame_switcher final

} // namespace plugin::gui::windows::main::widgets

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_FRAME_SWITCHER_H
