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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_FRAME_SELECTOR_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_FRAME_SELECTOR_H

#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/gui.h"
#include "plugin/types/singleton.h"
#include "plugin/types/not_null.h"

namespace plugin::gui::windows::main::widgets {

/// Widget for selecting and managing GUI frames.
///
/// Provides sidebar for selecting between different frames in main window.
/// Supports two states (collapsed/expanded) with smooth width transitions and
/// renders frame switcher buttons.
class frame_selector final : public types::singleton<frame_selector> {
private:
    static constexpr float default_width_on_state[2] = { 44, 200 };
    static constexpr float default_percentage_on_state[2] = {
        (default_width_on_state[0] * 100) / initializer::default_window_size.x, ///< ~6.29
        (default_width_on_state[1] * 100) / initializer::default_window_size.x, ///< ~28.58
    }; // static constexpr float default_percentage_on_state[2]

    static constexpr float title_font_size = 24;
    static constexpr float version_font_size = 18;

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;
    
    auto compute_width_on_state(bool state) const -> float;
    auto update_state_width() -> void;
    auto render_title() const -> void;
    auto render_frame_switchers() -> void;
    auto render_missing_rect() const -> void;
public:
    /// Valid pointer to the main window.
    types::not_null<initializer*> child;
    
    /// Width pair on certain menu states.
    std::pair<float, float> state_width;

    /// Current menu width.
    float width = state_width.first;

    /// Current menu visiblity state.
    bool state = false;

    /// Render frame selector.
    auto render() -> void;

    /// Constructor.
    ///
    /// @param window[in] Valid pointer to the main window.
    explicit frame_selector(types::not_null<initializer*> window)
        : child(window),
          state_width({ compute_width_on_state(false), compute_width_on_state(true) }),
          bold_font(window->child->fonts->bold),
          regular_font(window->child->fonts->regular) {}
}; // class frame_selector final : public types::singleton<frame_selector>

} // namespace plugin::gui::windows::main::widgets

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_FRAME_SELECTOR_H
