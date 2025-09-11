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


#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_INITIALIZER_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_INITIALIZER_H

#include "plugin/gui/windows/main/frames/frames.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/gui/base/window.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <imgui.h>

namespace plugin::gui::windows::main {

/// Main window initializer for GUI application.
///
/// Manages the main application window and its frames. Handles window movement,
/// rendering of active frames, and event processing.
class initializer final : public window {
private:
    std::array<frame_ptr_t, frames_count> frames;
    bool moving_window = false;

    auto render_active_frame() -> void;
    auto handle_window_moving() -> void;
public:
    /// Default window size.
    static constexpr ImVec2 default_window_size = { 800, 500 };

    /// Currently active frame.
    frame active_frame = frame::home;

    /// Screen size.
    std::pair<float, float> screen_size;
    
    /// Window flags.
    ImGuiWindowFlags window_flags = ImGuiWindowFlags_NoTitleBar;

    /// Window items alpha.
    std::uint8_t window_items_alpha = 255;

    /// Window padding.
    ImVec2 window_padding = { 0, 0 };

    /// Window position.
    ImVec2 window_pos = { 0, 0 };

    /// Window size.
    ImVec2 window_size = default_window_size;

    /// Get window ID.
    ///
    /// @return Window ID.
    inline auto get_id() const -> types::zstring_t override;

    /// Get window name.
    ///
    /// @return Window name.
    inline auto get_name() const -> types::zstring_t override;

    /// Handle SA-MP events.
    ///
    /// @param event SA-MP event information.
    /// @return True if event was handled.
    auto on_event(const samp::event_info& event) -> bool override;
    auto render() -> void override;

    /// Constructor.
    ///
    /// @param child GUI initializer.
    explicit initializer(types::not_null<gui_initializer*> child);
}; // class initializer final : public window


/// Create main window instance.
///
/// @param child GUI initializer.
/// @return Unique pointer to window.
auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

} // namespace plugin::gui::windows::main

inline auto plugin::gui::windows::main::initializer::get_id() const -> types::zstring_t {
    return "windows::main::initializer";
}

inline auto plugin::gui::windows::main::initializer::get_name() const -> types::zstring_t {
    return "Текущее окно";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_INITIALIZER_H
