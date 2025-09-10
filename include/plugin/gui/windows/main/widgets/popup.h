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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_POPUP_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_POPUP_H

#include "plugin/types/not_null.h"
#include "plugin/gui/windows/main/initializer.h"
#include <string>
#include <chrono>
#include <functional>

using namespace std::chrono_literals;

namespace plugin::gui::windows::main::widgets {

/// Widget for creating animated popup windows.
///
/// Provides functionality for creating popup windows with smooth open/close
/// animations. Supports custom content rendering through callback.
class popup final {
public:
    /// Callback type for rendering popup content.
    using renderer_t = std::function<void()>;
private:
    static constexpr std::chrono::milliseconds animation_duration = 500ms;
    static constexpr float close_button_height = 30;

    std::string id;
    renderer_t renderer = [] {};
    
    ImVec2 content_size = { 0, 0 };
    std::uint8_t window_alpha = 0;
    std::chrono::steady_clock::time_point time;
    bool active = false, closing = false;
public:
    /// Open popup with fade-in animation.
    auto open() -> void;

    /// Close popup with fade-out animation.
    auto close() -> void;

    /// Set custom content renderer.
    ///
    /// @param new_renderer[in] Renderer function.
    auto set_renderer(renderer_t new_renderer) -> void;

    /// Render popup.
    ///
    /// @param child[out] GUI initializer.
    auto render(types::not_null<initializer*> child) -> void;

    /// Constructor.
    ///
    /// @param id[in] Popup identifier.
    explicit popup(const std::string_view& id)
        : id(std::move(id)) {}
}; // class popup final

} // namespace plugin::gui::windows::main::widgets

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_POPUP_H
