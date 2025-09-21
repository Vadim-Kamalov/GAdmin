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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_INTERACTION_AREA_H
#define GADMIN_PLUGIN_GUI_WINDOWS_INTERACTION_AREA_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/hotkey.h"
#include "plugin/gui/gui.h"
#include "plugin/types/color.h"
#include "plugin/types/simple.h"
#include <optional>
#include <string>

namespace plugin::gui::windows {

/// Circular interaction menu for quick actions.
///
/// Provides radial menu for quick player and vehicle interactions.
/// Supports search for nearby objects and action execution through hotkeys.
class interaction_area final : public window {
private:
    enum class search_type : std::uint8_t {
        players,
        vehicles
    }; // enum class search_type : std::uint8_t

    enum class search_response : std::uint8_t {
        none,
        player_spectate,
        player_heal,
        player_stats,
        player_pame,
        player_gethere,
        vehicle_repair,
        vehicle_spawn,
        vehicle_fuel,
        vehicle_id,
        vehicle_gethere
    }; // enum class search_response : std::uint8_t
    
    static constexpr std::uint8_t response_player_offset = std::to_underlying(search_response::player_spectate);
    static constexpr std::uint8_t response_vehicle_offset = std::to_underlying(search_response::vehicle_repair);

    struct search_result final {
        ImVec2 point = { 0, 0 };
        float distance = 0;
        std::uint16_t id = 0;
        std::string description = "";
    }; // struct search_result final

    static constexpr int action_count_per_type = 5;
    static constexpr float fonts_size = 18;
    static constexpr types::zstring_t actions_description[][5] = {
        { "[2] Следить", "[3] Вылечить", "[4] Открыть статистику",
          "[5] Открыть /pame", "[6] Телепортировать к себе" },

        { "Починить [2]", "Заспавнить [3]", "Заправить [4]",
          "Узнать владельца [5]", "Телепортировать к себе [6]" }
    }; // static constexpr types::zstring_t actions_description[2]

    ImFont *bold_font, *regular_font;
    hotkey activation_hotkey;

    search_type current_search_type = search_type::players;
    search_response current_search_response = search_response::none;

    auto get_distance_between_points(float ax, float ay, float bx, float by) const -> float;

    auto find_player_nearby_to_screen_center(float radius) const -> std::optional<search_result>;
    auto find_vehicle_nearby_to_screen_center(float radius) const -> std::optional<search_result>;
    auto search_from_screen_center(float radius) const -> std::optional<search_result>;

    auto handle_controls() -> void;
    auto handle_search_response(std::uint16_t id) -> void;

    auto render_stroked_text(ImDrawList* draw_list, ImFont* font, const ImVec2& pos,
                             const types::color& color, types::zstring_t text) const -> void;

    auto render_help_text(ImDrawList* draw_list, float radius, const types::color& active_color,
                          const types::color& disabled_color) const -> void;

    auto render_search_description(ImDrawList* draw_list, float radius, const types::color& active_color,
                                   const std::string& search_description) const -> void;

    static consteval auto get_longest_action_description() noexcept -> types::zstring_t;
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
    explicit interaction_area(types::not_null<gui_initializer*> child);
}; // class interaction_area final : public window

} // namespace plugin::gui::windows

consteval auto plugin::gui::windows::interaction_area::get_longest_action_description()
    noexcept -> types::zstring_t
{
    types::zstring_t longest_description = "";
    std::size_t max_length = 0;

    for (const auto& group : actions_description) {
        for (const auto& description : group) {
            std::size_t description_length = std::char_traits<char>::length(description);
            if (description_length > max_length) {
                max_length = description_length;
                longest_description = description;
            }
        }
    }

    return longest_description;
}

inline auto plugin::gui::windows::interaction_area::get_id() const -> types::zstring_t {
    return "windows::interaction_area";
}

inline auto plugin::gui::windows::interaction_area::get_name() const -> types::zstring_t {
    return "Круговое меню";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_INTERACTION_AREA_H
