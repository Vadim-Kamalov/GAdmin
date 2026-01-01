/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2026 The Contributors.
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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_FRAME_SWITCHER_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_FRAME_SWITCHER_H

#include "plugin/gui/animation.h"
#include "plugin/gui/windows/main/frames/frames.h"
#include "plugin/gui/windows/main/widgets/frame_selector.h"
#include "plugin/types/color.h"
#include <chrono>

using namespace std::chrono_literals;

namespace plugin::gui::windows::main::widgets {

/// Widget for switching between different GUI frames.
///
/// Provides animated buttons for switching between different frames in main window.
/// Supports hover and click animations with customizable appearance and behavior.
class frame_switcher final {
private:
    static constexpr float button_default_height = 30;
    static constexpr float button_height_percent =
        (button_default_height * 100.0f) / initializer::default_window_size.y; ///< ~6.6

    static constexpr std::chrono::milliseconds click_animation_duration = 200ms;
    static constexpr std::chrono::milliseconds hover_animation_duration = 400ms;
    
    static constexpr std::chrono::milliseconds fade_in_duration = 150ms;
    static constexpr std::chrono::milliseconds fade_out_duration = 300ms;
    static constexpr std::chrono::milliseconds fade_in_out_duration = fade_in_duration + fade_out_duration;

    static constexpr float icon_font_size = 24;
    static constexpr float text_font_size = 18;

    types::not_null<frame_selector*> child;
    types::color current_color;
    std::chrono::steady_clock::time_point time_clicked;
    animation::hover_info hover_info;
   
    ImFont* icon_font = nullptr;
    ImFont* bold_font = nullptr;
    ImVec2 button_size = { 0, 0 };
    frame switch_frame;

    auto handle_frame_switching() -> void;
    auto update_button_size() -> void;
    auto update_current_color() -> void;
    auto render_button() -> void;
public:
    /// Render frame switcher button.
    auto render() -> void;

    /// Get frame switcher instance from pool.
    ///
    /// @param child[in]        Frame selector instance.
    /// @param switch_frame[in] Target frame to switch to.
    /// @return                 Reference to frame switcher instance.
    static auto get_from_pool(types::not_null<frame_selector*> child, const frame& switch_frame)
        noexcept -> std::unique_ptr<frame_switcher>&;

    /// Constructor.
    ///
    /// @param frame_selector[in] Parent frame selector.
    /// @param switch_frame[in]   Target frame to switch to.
    explicit frame_switcher(types::not_null<frame_selector*> frame_selector, const frame& switch_frame)
        : child(frame_selector),
          switch_frame(switch_frame),
          icon_font(frame_selector->child->child->fonts->icon),
          bold_font(frame_selector->child->child->fonts->bold) {}
}; // class frame_switcher final

} // namespace plugin::gui::windows::main::widgets

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_FRAME_SWITCHER_H
