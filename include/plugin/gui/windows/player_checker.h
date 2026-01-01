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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_PLAYER_CHECKER_H
#define GADMIN_PLUGIN_GUI_WINDOWS_PLAYER_CHECKER_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/gui/widgets/aligner.h"
#include "plugin/types/color.h"
#include "plugin/types/simple.h"
#include <deque>

namespace plugin::gui::windows {

/// Window for checking player information.
///
/// Provides interface for viewing player information, status and notes.
/// Supports player state notifications and customizable display options.
class player_checker final : public window {
public:
    enum class align_t : std::uint8_t {
        left,
        center,
        right
    }; // enum class align_t : std::uint8_t
private:
    static constexpr float title_font_size = 20;
    static constexpr float common_font_size = 18;
    static constexpr float text_border_size = 1;
    static constexpr std::uint16_t id_none = 0xFFFF;
    static constexpr types::zstring_t title_text = "Чекер игроков";

    struct entry_t final {
        std::string nickname, description;
        types::color nickname_color;
        std::uint16_t id = id_none;
        widgets::aligner aligner;

        auto to_string() const -> std::string;
    }; // struct entry_t final

    struct window_information_t final {
        struct render_configuration_t final {
            bool render : 1 = false;
            bool show_title : 1 = false;
            bool show_offline : 1 = false;
        } render_configuration;

        widgets::aligner title_aligner;
        std::deque<entry_t> entries;
        float width = 0.0f;
    }; // struct window_information_t final
    
    struct state_notification_t final {
        struct configuration_t final {
            bool disconnected : 1 = false;
            bool notify : 1 = false;
            bool sound_notify : 1 = false;
        } configuration;

        std::string nickname;
        std::uint16_t id;
    }; // struct state_notification_t final

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    auto get_render_safe_color(const types::color& color) const -> types::color;
    auto get_entry_width(const entry_t& entry, bool show_offline) const -> float;
    auto get_window_information() const -> window_information_t;
    auto send_state_notification(const state_notification_t& notification) const -> void;
public:
    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;
    inline auto without_background() const -> bool override;

    auto on_event(const samp::event_info& event) -> bool override;
    auto render() -> void override;

    /// Create instance of the current window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    /// @return          Unique pointer to window.
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    /// Construct the window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    explicit player_checker(types::not_null<gui_initializer*> child)
        : window(child, get_id()),
          bold_font(child->fonts->bold),
          regular_font(child->fonts->regular) {}
}; // class player_checker final : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::player_checker::get_id() const -> types::zstring_t {
    return "windows::player_checker";
}

inline auto plugin::gui::windows::player_checker::get_name() const -> types::zstring_t {
    return "Чекер игроков";
}

inline auto plugin::gui::windows::player_checker::without_background() const -> bool {
    return true;
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_PLAYER_CHECKER_H
