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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_SUBMENU_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_SUBMENU_H

#include "plugin/types/not_null.h"
#include "plugin/gui/windows/main/initializer.h"
#include <string>
#include <any>
#include <vector>
#include <functional>
#include <chrono>

using namespace std::chrono_literals;

namespace plugin::gui::windows::main::widgets {

/// Widget for creating animated submenus with customizable entries.
///
/// Provides functionality for creating interactive submenus with smooth animations
/// for adding/removing entries. Supports custom rendering of each entry and provides
/// callbacks for entry destruction and addition.
class submenu final {
public:
    /// Callback type for rendering individual frame entries.
    using frame_renderer_t = std::function<void(std::string& label, std::any& payload)>;

    /// Callback type for handling entry destruction.
    using on_entry_destroy_callback_t = std::function<void(std::size_t index)>;

    /// Callback type for handling new entry addition.
    using add_callback_t = std::function<void()>;
private:
    static constexpr std::chrono::milliseconds fade_in_duration = 150ms;
    static constexpr std::chrono::milliseconds fade_out_duration = 300ms;
    static constexpr std::chrono::milliseconds fade_in_out_duration = fade_in_duration + fade_out_duration;
    static constexpr std::chrono::milliseconds entry_animation_duration = fade_in_duration;
    
    static constexpr float title_font_size = 24;
    static constexpr float empty_placeholder_font_size = 18;
    static constexpr float child_default_width = 190;
    static constexpr float switch_button_default_height = 30;

    static constexpr float child_width_percent =
        (child_default_width * 100.0f) / initializer::default_window_size.x; ///< 23.75%

    static constexpr float switch_button_percent =
        (switch_button_default_height * 100.0f) / initializer::default_window_size.y; ///< 6%
    
    struct entry_t final {
        std::string label;
        std::any payload;
        std::chrono::steady_clock::time_point animation_time;
        float alpha = 1.00;
        bool hiding = false;
    }; // struct entry_t final

    frame_renderer_t frame_renderer = [](auto&, auto&) {};
    std::optional<on_entry_destroy_callback_t> on_entry_destroy_callback;
    std::optional<add_callback_t> add_callback;

    std::vector<entry_t> entries;
    std::string label;
    types::zstring_t selected_empty_placeholder;
   
    std::size_t future_entry_index = 0;
    std::size_t current_entry_index = 0;

    float frame_alpha = 1.00;
    std::chrono::steady_clock::time_point time_clicked;

    auto get_next_available_entry_index() const -> std::size_t;
    auto render_entry(std::size_t index, entry_t& entry, const ImVec2& size) -> void;
public:
    /// Get total number of entries in submenu.
    ///
    /// @return Number of entries.
    auto get_total_entries() const -> std::size_t;

    /// Get index of currently selected entry.
    ///
    /// @return Current entry index.
    auto get_current_entry_index() const -> std::size_t;

    /// Add new entry to submenu without animation.
    ///
    /// @param label[in]   Entry label.
    /// @param payload[in] Entry payload data.
    auto add_entry(const std::string_view& label, const std::any& payload) -> void;

    /// Add new entry with fade-in animation.
    ///
    /// @param label[in]   Entry label.
    /// @param payload[in] Entry payload data.
    auto add_entry_animated(const std::string_view& label, const std::any& payload) -> void;

    /// Remove currently selected entry with fade-out animation.
    auto remove_current_entry_animated() -> void;

    /// Set callback for entry destruction.
    ///
    /// @param new_callback[in] Callback function.
    auto set_on_entry_destroyed_callback(on_entry_destroy_callback_t new_callback) -> void;

    /// Set callback for new entry addition.
    ///
    /// @param new_callback[in] Callback function.
    auto set_add_callback(add_callback_t new_callback) -> void;

    /// Set custom renderer for frame entries.
    ///
    /// @param new_frame_renderer[in] Renderer function.
    auto set_frame_renderer(frame_renderer_t new_frame_renderer) -> void;
    
    /// Render submenu interface.
    ///
    /// @param child[in] Valid pointer to the main window.
    auto render_menu(types::not_null<initializer*> child) -> void;

    /// Render currently selected frame.
    ///
    /// @param child[in] Valid pointer to the main window.
    auto render_current_frame(types::not_null<initializer*> child) -> void;

    /// Construct submenu.
    ///
    /// @param label[in] Label of the submenu.
    explicit submenu(const std::string_view& label);
}; // class submenu final

} // namespace plugin::gui::windows::main::widgets

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_SUBMENU_H
