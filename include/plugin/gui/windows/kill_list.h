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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_KILL_LIST_H
#define GADMIN_PLUGIN_GUI_WINDOWS_KILL_LIST_H

#include "plugin/samp/events/player_death_notification.h"
#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/samp/player.h"
#include "plugin/types/color.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <optional>

using namespace std::chrono_literals;

namespace plugin::gui::windows {

/// Window for displaying kill list.
///
/// Shows kill list log from the server with timestamps and reasons.
class kill_list final : public window {
private:
    static constexpr float title_font_size = 20;
    static constexpr float common_font_size = 18;
    static constexpr float text_border_size = 1;
    static constexpr types::zstring_t title_text = "Килл-лист";

    struct player_t final {
        std::string nickname;
        std::uint16_t id;
        types::color color;

        auto to_string() const -> std::string;
        auto render(bool clist_color, ImFont* font) const -> void;

        explicit player_t(const samp::player& player)
            : nickname(player.nickname), id(player.id),
              color(get_render_safe_color(player.get_color())) {}
    }; // struct player_t final

    struct entry_t final {
        player_t left;
        std::optional<player_t> right;
        std::string reason, time;
        float width = 0.0f;
    }; // struct entry_t final

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    float max_entry_width = 0;
    std::deque<entry_t> entries;

    static auto get_render_safe_color(const types::color& color) noexcept -> types::color;
    auto get_window_size(bool show_title) const -> ImVec2;
    auto update_max_entry_width() -> void;
    auto write_entry_width(entry_t& entry) -> void;
    auto try_write_entry_right_player(std::uint16_t id, entry_t& entry) const -> void;
    auto on_player_death_notification(const samp::event<samp::event_id::player_death_notification>& notification) -> bool;
public:
    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;

    auto render() -> void override;
    auto on_event(const samp::event_info& event) -> bool override;

    /// Create instance of the current window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    /// @return          Unique pointer to window.
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    /// Construct the window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    explicit kill_list(types::not_null<gui_initializer*> child)
        : window(child, get_id()),
          bold_font(child->fonts->bold),
          regular_font(child->fonts->regular) {}
}; // class kill_list : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::kill_list::get_id() const -> types::zstring_t {
    return "windows::kill_list";
}

inline auto plugin::gui::windows::kill_list::get_name() const -> types::zstring_t {
    return "Килл-лист";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_KILL_LIST_H
