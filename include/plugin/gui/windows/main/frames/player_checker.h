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
/// 
/// @file plugin/gui/windows/main/frames/player_checker.h
/// @brief Defines the player checker frame in the GUI.


#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_PLAYER_CHECKER_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_PLAYER_CHECKER_H

#include "plugin/gui/widgets/search.h"
#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/gui/gui.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <nlohmann/json.hpp>
#include <deque>

namespace plugin::gui::windows::main::frames {

/// @class player_checker
 /// @brief Represents the player checker frame in the GUI.
class player_checker final : public basic_frame {
private:
    static constexpr float bottom_button_height = 30;
    static constexpr float title_font_size = 24;
    static constexpr float common_font_size = 18;
    static constexpr std::uint16_t id_none = 0xFFFF;
    static constexpr types::zstring_t description_hint = "Заметка об игроке";

    struct player_online_t final {
        std::string nickname;
        std::uint16_t id;
    }; // struct player_online_t final

    struct added_player_t final {
        std::string nickname;
        std::string description;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(added_player_t, nickname, description);
    }; // struct added_player_t final

    types::not_null<initializer*> child;
    gui::widgets::search search = gui::widgets::search("frames::player_checker::search");

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;
    
    std::string description_text = "";
    std::uint16_t selected_id = id_none;
    std::size_t selected_player_index = 0;

    auto get_filtered_player_list() const -> std::deque<player_online_t>;
    static auto get_added_players_json() -> nlohmann::json&;
    auto render_description_hint(const ImVec2& input_size) const -> void;
    auto render_left_group(float width) -> void;
    auto render_right_group(float width) -> void;
public:
    /// @brief Renders the player checker frame.
    auto render() -> void override;

    /// @brief Constructor for the player checker frame.
    /// @param child The GUI initializer.
    explicit player_checker(types::not_null<initializer*> child);
}; // class player_checker final

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_PLAYER_CHECKER_H
