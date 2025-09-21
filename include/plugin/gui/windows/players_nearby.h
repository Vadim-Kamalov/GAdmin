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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_PLAYERS_NEARBY_H
#define GADMIN_PLUGIN_GUI_WINDOWS_PLAYERS_NEARBY_H

#include "nlohmann/detail/macro_scope.hpp"
#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/types/color.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <deque>

namespace plugin::gui::windows {

/// Window for displaying players in streaming zone.
///
/// Shows list of players nearby with their distance and ID.
/// Supports sorting by different criteria and customizable display.
class players_nearby final : public window {
public:
    /// Sorting options for player list.
    enum class sort_option_t { disabled, length, distance, id };
private:
    static constexpr float title_font_size = 18;
    static constexpr float entry_font_size = 16;

    struct entry final {
        float width = 0;
        float distance = 0;
        std::string text = "";
        std::uint16_t id = 0;
        types::color color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Text]);
    }; // struct entry final

    struct information_t final {
        ImVec2 content_size;
        std::deque<entry> entries;
    }; // struct information_t final

    ImFont* title_font;
    ImFont* entry_font;

    auto get_window_information() const -> information_t;
public:
    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;

    auto render() -> void override;

    /// Create instance of the current window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    /// @return          Unique pointer to window.
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    /// Construct the window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    explicit players_nearby(types::not_null<gui_initializer*> child)
        : window(child, get_id()),
          title_font(child->fonts->bold),
          entry_font(child->fonts->regular) {}
private:
    static constexpr std::size_t text_border_size = 1;
    static constexpr types::zstring_t title = "Игроки в зоне стрима";
}; // class players_nearby final : public window

NLOHMANN_JSON_SERIALIZE_ENUM(players_nearby::sort_option_t, {
    { players_nearby::sort_option_t::disabled, "disabled" },
    { players_nearby::sort_option_t::length, "length" },
    { players_nearby::sort_option_t::distance, "distance"},
    { players_nearby::sort_option_t::id, "id" }
})

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::players_nearby::get_id() const -> types::zstring_t {
    return "windows::players_nearby";
}

inline auto plugin::gui::windows::players_nearby::get_name() const -> types::zstring_t {
    return "Игроки рядом";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_PLAYERS_NEARBY_H
