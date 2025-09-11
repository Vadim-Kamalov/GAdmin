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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_NOTIFY_H
#define GADMIN_PLUGIN_GUI_WINDOWS_NOTIFY_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/gui/notify.h"
#include "plugin/types/simple.h"
#include "plugin/types/not_null.h"

namespace plugin::gui::windows {

/// Window for displaying notifications.
///
/// Shows system notifications with icons, text and action buttons.
/// Supports customizable notification appearance and button handling.
class notify final : public window {
private:
    static constexpr float icon_font_size = 24;
    static constexpr float bold_font_size = 18;
    static constexpr float regular_font_size = 16;

    float height = 0;

    auto on_send_notification(notification& notification) -> bool;
    auto get_buttons_max_size(ImFont* font, float font_size, const notification::buttons_t& buttons) const -> ImVec2;
    
    auto render_button(const ImVec2& pos, ImFont* font, float font_size, notification& notification,
                       notification::button& button) const -> void;
    
    auto render_notification(notification& item) const -> void;
public:
    /// Get window ID.
    ///
    /// @return Window ID.
    inline auto get_id() const -> types::zstring_t override;

    /// Get window name.
    ///
    /// @return Window name.
    inline auto get_name() const -> types::zstring_t override;
 
    /// Create notify window instance.
    ///
    /// @param child GUI initializer.
    /// @return Unique pointer to window.
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    /// Render notify window.
    auto render() -> void override;

    /// Constructor.
    ///
    /// @param child GUI initializer.
    explicit notify(types::not_null<gui_initializer*> child);
private:
    static constexpr float notification_size[2] = { 400, 70 };
    static constexpr float padding = 10;
}; // class notify final : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::notify::get_id() const -> types::zstring_t {
    return "windows::notify";
}

inline auto plugin::gui::windows::notify::get_name() const -> types::zstring_t {
    return "Оповещения";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_NOTIFY_H
