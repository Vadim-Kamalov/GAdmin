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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_SPECTATOR_INFORMATION_H
#define GADMIN_PLUGIN_GUI_WINDOWS_SPECTATOR_INFORMATION_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/types/color.h"
#include "plugin/types/simple.h"
#include "plugin/types/not_null.h"
#include <imgui.h>
#include <functional>

namespace plugin::gui::windows {

/// Window for displaying spectator information.
///
/// Shows detailed information about spectated player including statistics,
/// vehicle information and other relevant data. Supports custom rendering
/// for different types of information.
class spectator_information final : public window {
private:
    static constexpr float min_wrap_width = 80;
    static constexpr float fonts_size = 16;

    class row final {
    public:
        using color_updater_t = std::function<types::color()>;
        using custom_renderer_t = std::function<void(std::string_view, types::color)>;
    private:
        std::optional<color_updater_t> updater;
        std::optional<custom_renderer_t> custom_renderer;
    public:
        std::string value = "";
        std::string label = "";
        types::color color = ImGui::GetColorU32(ImGuiCol_Text);
        
        inline auto is_updater_available() const -> bool { return updater.has_value(); }
        inline auto update_color() -> void { color = (*updater)(); }

        inline auto is_custom_renderer_available() const -> bool { return custom_renderer.has_value(); }
        inline auto use_custom_renderer() const -> void { (*custom_renderer)(value, color); }

        explicit row(const std::string_view& label, const std::string_view& value, color_updater_t updater)
            : label(std::move(label)), value(std::move(value)), updater(updater) { color = updater(); }

        explicit row(const std::string_view& label, const std::string_view& value)
            : label(std::move(label)), value(value) {}

        explicit row(const std::string_view& label, const std::string_view& value, custom_renderer_t custom_renderer)
            : label(std::move(label)), value(std::move(value)), custom_renderer(custom_renderer) {}
    }; // class row final
    
    ImFont* bold_font;
    ImFont* regular_font;

    auto vehicles_custom_renderer(const std::string_view& value, types::color color) const -> void;
    auto vehicle_information_custom_renderer(const std::string_view&, types::color) const -> void;
    auto nickname_custom_renderer(const std::string_view& value, types::color color) const -> void;

    auto get_time_spectated() const -> std::string;
    auto get_rows() const -> std::vector<row>;
    
    auto render_centered_text(const std::string_view& value, ImFont* font,
                              const ImVec4& color = ImGui::GetStyle().Colors[ImGuiCol_Text]) const -> void;
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
    explicit spectator_information(types::not_null<gui_initializer*> child)
        : window(child, get_id()),
          bold_font(child->fonts->bold),
          regular_font(child->fonts->regular) {}
}; // class spectator_information final : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::spectator_information::get_id() const -> types::zstring_t {
    return "windows::spectator_information";
}

inline auto plugin::gui::windows::spectator_information::get_name() const -> types::zstring_t {
    return "Информация в /sp";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_SPECTATOR_INFORMATION_H
