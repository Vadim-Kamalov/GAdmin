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

#ifndef GADMIN_PLUGIN_GUI_STYLE_H
#define GADMIN_PLUGIN_GUI_STYLE_H

#include "plugin/types/color.h"
#include <nlohmann/json.hpp>
#include <imgui.h>
#include <unordered_map>

namespace plugin::gui {

/// Provides methods for interactions with the global interface
/// theme style: accessing, saving and applying it.
class style final {
public:
    /// Represents interface color scheme.
    struct interface_colors_t final {
        std::array<types::color, 2> surface; ///< Surface colors (background, secondary background).
        std::array<types::color, 2> text;    ///< Text colors (primary, secondary).
        std::array<types::color, 3> overlay; ///< Overlay colors (primary, secondary, tertiary).

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(interface_colors_t, surface, text, overlay);
    }; // struct interface_colors_t final

    /// Represents interface accent colors.
    struct accent_colors_t final {
        types::color green;  ///< Color to indicate success/positive actions.
        types::color red;    ///< Color to indicate errors/negative actions.
        types::color yellow; ///< Color to indicate warnings/neutral actions.
        
        NLOHMANN_DEFINE_TYPE_INTRUSIVE(accent_colors_t, green, red, yellow);
    }; // struct accent_colors_t final

    /// Represents complete theme with color scheme and accent colors.
    struct theme_t final {
        interface_colors_t interface_colors; ///< Theme's interface colors.
        accent_colors_t accent_colors;       ///< Theme's accent colors.

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(theme_t, interface_colors, accent_colors);
    }; // struct theme_t final

    /// Used ImGui colors in the interface.
    static const std::vector<ImGuiCol> used_colors;

    /// Descriptions of the used ImGui colors in the interface.
    static const std::vector<std::string> colors_placeholders;
private:
    static inline theme_t current_theme;
    static inline std::unordered_map<ImGuiCol, ImVec4> global_colors;

    static auto apply_theme(ImGuiStyle& style, const theme_t& theme) noexcept -> void;
    static auto set_color(ImGuiStyle& style, ImGuiCol color_index, const ImVec4& color) noexcept -> void;
public:
    /// Get current accent colors.
    ///
    /// @return Current accent color scheme.
    static inline auto get_current_accent_colors() noexcept -> accent_colors_t&;
    
    /// Get global ImGui color by index.
    ///
    /// @param color_index[in] ImGui color index.
    /// @return                Color as `ImVec4`.
    static inline auto get_global_color(ImGuiCol color_index) -> ImVec4;

    /// Get saved theme from configuration.
    ///
    /// @return JSON reference to saved theme.
    static auto get_saved_theme() -> nlohmann::json&;

    /// Apply specified theme.
    ///
    /// @param theme[in] Theme to apply.
    static auto apply_theme(const theme_t& theme) -> void;

    /// Apply current theme: previously loaded or default theme.
    static auto apply() -> void;
}; // class style final

} // namespace plugin::gui

inline auto plugin::gui::style::get_current_accent_colors() noexcept -> accent_colors_t& {
    return current_theme.accent_colors;
}

inline auto plugin::gui::style::get_global_color(ImGuiCol color_index) -> ImVec4 {
    return global_colors[color_index];
}

#endif // GADMIN_PLUGIN_GUI_STYLE_H
