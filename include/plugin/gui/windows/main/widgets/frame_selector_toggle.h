#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_FRAME_SELECTOR_TOGGLE_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_FRAME_SELECTOR_TOGGLE_H

#include "plugin/gui/animation.h"
#include "plugin/gui/icon.h"
#include "plugin/types/color.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include "plugin/types/singleton.h"
#include "plugin/gui/windows/main/widgets/frame_selector.h"
#include <chrono>

using namespace std::chrono_literals;

namespace plugin::gui::windows::main::widgets {

class frame_selector_toggle final : public types::singleton<frame_selector_toggle> {
private:
    static constexpr std::chrono::milliseconds animation_duration = 500ms;
    static constexpr std::chrono::milliseconds width_change_duration = 500ms;
    static constexpr types::zstring_t icon = ICON_HAMBURGER_M_D;
    static constexpr float icon_font_size = 24;

    ImFont* icon_font = nullptr;
    
    types::not_null<frame_selector*> child;
    types::color current_color;
    
    std::chrono::steady_clock::time_point time_clicked;
    animation::hover_info hover_info;

    auto handle_hover_animation() -> void;
    auto render_rect_with_icon() -> void;
    auto update_menu_width() -> void;
public:
    auto switch_menu_state() -> void;
    auto render() -> void;

    explicit frame_selector_toggle(types::not_null<frame_selector*> frame_selector)
        : child(frame_selector), icon_font(frame_selector->child->child->fonts->icon) {}
}; // class frame_selector_toggle final : public types::singleton<frame_selector_toggle>

} // namespace plugin::gui::windows::main::widgets

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_FRAME_SELECTOR_TOGGLE_H
