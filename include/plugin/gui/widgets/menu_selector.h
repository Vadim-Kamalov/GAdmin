#ifndef GADMIN_PLUGIN_GUI_WIDGETS_MENU_SELECTOR_H
#define GADMIN_PLUGIN_GUI_WIDGETS_MENU_SELECTOR_H

#include "plugin/utils.h"
#include "plugin/gui/windows/main.h"
#include <imgui.h>
#include <chrono>

namespace plugin::gui::widgets {

struct MenuSelectorAnimation {
    ImVec4 color;
    bool hovered_state_current = false, hovered_state_previous = false;
    std::chrono::milliseconds duration = std::chrono::milliseconds(500);
    std::chrono::steady_clock::time_point hovered_time, click_time;
}; // struct MenuSelectorAnimation

void menu_selector(utils::not_null<windows::Main*> child) noexcept;

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_MENU_SELECTOR_H
