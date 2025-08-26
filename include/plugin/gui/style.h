#ifndef GADMIN_PLUGIN_GUI_STYLE_H
#define GADMIN_PLUGIN_GUI_STYLE_H

#include "plugin/types/color.h"
#include <nlohmann/json.hpp>
#include <imgui.h>
#include <unordered_map>

namespace plugin::gui {

class style final {
public:
    struct interface_colors_t final {
        std::array<types::color, 2> surface;
        std::array<types::color, 2> text;
        std::array<types::color, 3> overlay;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(interface_colors_t, surface, text, overlay);
    }; // struct interface_colors_t final

    struct accent_colors_t final {
        types::color green;
        types::color red;
        types::color yellow;
        
        NLOHMANN_DEFINE_TYPE_INTRUSIVE(accent_colors_t, green, red, yellow);
    }; // struct accent_colors_t final

    struct theme_t final {
        interface_colors_t interface_colors;
        accent_colors_t accent_colors;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(theme_t, interface_colors, accent_colors);
    }; // struct theme_t final

    static const std::vector<ImGuiCol> used_colors;
    static const std::vector<std::string> colors_placeholders;
private:
    static inline theme_t current_theme = {
        .interface_colors = {
            .surface = { 0xFF241717, 0xFF2E1D1D },
            .text = { 0xFFDEC2BA, 0xFF5A4745 },
            .overlay = { 0xFF3F302F, 0xFF4E3E3C, 0xFF372A2A }
        },
        .accent_colors = {
            .green = 0xFFA1E3A6,
            .red = 0xFFA88BF3,
            .yellow = 0xFFAEE2F9
        }
    }; // static inline theme_t current_theme

    static inline std::unordered_map<ImGuiCol, ImVec4> global_colors;

    static auto apply_theme(ImGuiStyle& style, const theme_t& theme) noexcept -> void;
    static auto set_color(ImGuiStyle& style, ImGuiCol color_index, const ImVec4& color) noexcept -> void;
public:
    static inline auto get_current_accent_colors() noexcept -> accent_colors_t;
    static inline auto get_global_color(ImGuiCol color_index) -> ImVec4;

    static auto get_saved_theme() -> nlohmann::json&;
    static auto apply_theme(const theme_t& theme) -> void;

    static auto apply() -> void;
}; // class style final

} // namespace plugin::gui

inline auto plugin::gui::style::get_current_accent_colors() noexcept -> accent_colors_t {
    return current_theme.accent_colors;
}

inline auto plugin::gui::style::get_global_color(ImGuiCol color_index) -> ImVec4 {
    return global_colors[color_index];
}

#endif // GADMIN_PLUGIN_GUI_STYLE_H
