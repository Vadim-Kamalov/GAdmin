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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_KEY_BINDS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_KEY_BINDS_H

#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/gui/hotkey.h"
#include "plugin/gui/gui.h"
#include "plugin/types/not_null.h"

namespace plugin::gui::windows::main::frames {

/// Represents a frame in the main window that allows configuring hotkeys.
class key_binds final : public basic_frame {
private:
    static constexpr float title_font_size = 24;
    static constexpr float common_font_size = 18;

    static constexpr ImVec2 buttons_size_percentage = {
        (hotkey::default_button_size.x * 100) / initializer::default_window_size.x, ///< ~14.29
        (hotkey::default_button_size.y * 100) / initializer::default_window_size.y, ///< ~6.6
    }; // static constexpr ImVec2 button_size_percentage

    ImVec2 buttons_size;
    types::not_null<initializer*> child;
    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    auto get_buttons_size() -> ImVec2;
public:
    auto render() -> void override;

    /// Construct the frame.
    ///
    /// @param child[in] Valid pointer to the main window.
    explicit key_binds(types::not_null<initializer*> child)
        : child(child),
          bold_font(child->child->fonts->bold),
          regular_font(child->child->fonts->regular) {}
}; // class key_binds final

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_KEY_BINDS_H
