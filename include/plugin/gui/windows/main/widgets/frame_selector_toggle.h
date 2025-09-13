/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

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

/// Toggle button for frame selector menu.
///
/// Provides animated toggle button for expanding/collapsing frame selector menu.
/// Supports hover animations, color transitions and menu width changes.
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
    auto handle_background() -> void;
    auto render_rect_with_icon() -> void;
    auto update_menu_width() -> void;
public:
    /// Toggle menu state between expanded and collapsed.
    auto switch_menu_state() -> void;

    /// Render toggle button with current state.
    auto render() -> void;

    /// Constructor.
    ///
    /// @param frame_selector[in] Parent frame selector instance.
    explicit frame_selector_toggle(types::not_null<frame_selector*> frame_selector)
        : child(frame_selector), icon_font(frame_selector->child->child->fonts->icon) {}
}; // class frame_selector_toggle final : public types::singleton<frame_selector_toggle>

} // namespace plugin::gui::windows::main::widgets

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_FRAME_SELECTOR_TOGGLE_H
