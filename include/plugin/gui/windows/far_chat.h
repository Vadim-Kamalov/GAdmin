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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_FAR_CHAT_H
#define GADMIN_PLUGIN_GUI_WINDOWS_FAR_CHAT_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/samp/events/event.h"
#include "plugin/samp/events/player_chat_bubble.h"
#include "plugin/samp/player.h"
#include "plugin/types/color.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <chrono>
#include <deque>

namespace plugin::gui::windows {

/// Window for displaying distant chat messages.
///
/// Shows chat messages from distant players with timestamps and player information.
/// Supports message filtering and duplicate detection.
class far_chat final : public window {
private:
    static constexpr float title_font_size = 20;
    static constexpr float common_font_size = 18;
    static constexpr std::size_t text_border_size = 1;
    static constexpr types::zstring_t title_text = "Дальний чат";

    struct entry_t final {
        samp::player player;
        types::color player_color, message_color;
        std::string message, time;
        std::chrono::steady_clock::time_point steady_time;
    }; // struct entry_t final

    ImFont* regular_font = nullptr;
    ImFont* bold_font = nullptr;

    std::deque<entry_t> entries;

    auto get_render_safe_color(const types::color& color) const -> types::color;
    auto is_duplicate_entry(const std::string_view& message, std::uint16_t player_id, std::chrono::milliseconds delay) const -> bool;
    auto on_player_chat_bubble(const samp::event<samp::event_id::player_chat_bubble>& event) -> bool;
public:
    /// Get window ID.
    ///
    /// @return Window ID.
    inline auto get_id() const -> types::zstring_t override;

    /// Get window name.
    ///
    /// @return Window name.
    inline auto get_name() const -> types::zstring_t override;

    /// Create far chat window instance.
    ///
    /// @param child GUI initializer.
    /// @return Unique pointer to window.
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    /// Handle SA-MP events.
    ///
    /// @param event SA-MP event information.
    /// @return True if event was handled.
    auto on_event(const samp::event_info& event) -> bool override;

    /// Render far chat window.
    auto render() -> void override;

    /// Constructor.
    ///
    /// @param child GUI initializer.
    explicit far_chat(types::not_null<gui_initializer*> child)
        : window(child, get_id()),
          regular_font(child->fonts->regular),
          bold_font(child->fonts->bold) {}
}; // class far_chat final : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::far_chat::get_id() const -> types::zstring_t {
    return "windows::far_chat";
}

inline auto plugin::gui::windows::far_chat::get_name() const -> types::zstring_t {
    return "Дальний чат";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_FAR_CHAT_H
