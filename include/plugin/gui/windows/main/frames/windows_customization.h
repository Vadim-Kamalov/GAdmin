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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_WINDOWS_CUSTOMIZATION_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_WINDOWS_CUSTOMIZATION_H

#include "plugin/gui/style.h"
#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/gui/windows/main/widgets/submenu.h"
#include "plugin/gui/windows/main/widgets/popup.h"
#include "plugin/types/not_null.h"
#include <nlohmann/json.hpp>
#include <unordered_map>
#include <deque>
#include <thread>

namespace plugin::gui::windows::main::frames {

/// Represents the window customization and theme downloading in the main window.
class windows_customization final : public basic_frame {
private:
    static constexpr float title_font_size = 24;
    static constexpr float common_font_size = 18;
    static constexpr float buttons_height = 30;

    struct user_theme_t final {
        std::string name;
        std::string author;
        style::theme_t theme;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(user_theme_t, name, author, theme);
    }; // struct user_theme_t final

    std::unordered_map<std::string, ImVec4> color_pool;

    types::not_null<initializer*> child;
    widgets::submenu submenu = widgets::submenu("Оформление окон##frames::windows_customization");
    widgets::popup popup = widgets::popup("frames::windows_customization::popup");

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    std::string copied_id = "";
    std::deque<user_theme_t> user_themes;
    std::jthread network_thread;

    static auto get_windows_customization() -> nlohmann::json&;

    auto render_color_edit(types::zstring_t label, const std::string& id, nlohmann::json& setter) -> void;
    auto render_accent_color_edit(types::zstring_t label, const std::string& id) -> void;
    auto render_interface_color_edit(types::zstring_t label, const std::string& id, std::size_t index) -> void;
    auto render_global_theme_frame() -> void;
    
    auto update_color_edit_values(const std::string_view& id, std::size_t index, const ImVec4& value) const -> void;
    auto get_color_edit_values(const std::string_view& id, std::size_t index) const -> ImVec4;
    
    auto paste_settings(const std::string_view& id) const -> void;
    auto reset_settings(const std::string_view& id) const -> void;
    auto apply_settings_for_all(const std::string_view& id) const -> void;

    auto render_window_customization_buttons(const std::string_view& id, const ImVec2& button_size) -> void;
    auto render_window_customization(const std::string_view& id) -> void;

    auto write_user_themes() -> void;
    auto popup_renderer() -> void;
    auto frame_renderer(std::string& label, std::any& payload) -> void;
public:
    auto render() -> void override;

    /// Construct the frame.
    ///
    /// @param child[in] Valid pointer to the main window.
    explicit windows_customization(types::not_null<initializer*> child);
}; // class windows_customization final

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_WINDOWS_CUSTOMIZATION_H
