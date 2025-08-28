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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_BINDER_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_BINDER_H

#include "plugin/gui/hotkey.h"
#include "plugin/gui/widgets/search.h"
#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/gui/windows/main/widgets/binder_variables_popup.h"
#include "plugin/gui/windows/main/widgets/submenu.h"
#include "plugin/samp/events/send_command.h" // IWYU pragma: keep
#include "plugin/types/not_null.h"
#include <nlohmann/json.hpp>

namespace plugin::gui::windows::main::frames {

/// Represents a frame in the main window for managing and configuring binds.
///
/// When a new bind is created, a new hotkey is automatically generated and
/// assigned to it using a UUID. This UUID is used to determine which bind
/// is activated by the hotkey and to execute the associated binder string.
///
/// Each bind can be configured to use a hotkey, a command, or both. When
/// activated, the user's input text is evaluated: all variables are replaced
/// with their actual values, and the result is inserted into the chat or its
/// input frame.
class binder final : public basic_frame {
private:
    static constexpr float title_font_size = 24;
    static constexpr float common_font_size = 18;
    static constexpr float buttons_height = 30;
    static constexpr ImVec2 popup_scrollable_area_size = { 450, 600 };

    struct bind_t final {
        std::string uuid;
        std::string title;
        std::string command_name;
        std::string text;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(bind_t, uuid, title, command_name, text);
    }; // struct bind_t final

    std::string variable_parameter;
    types::not_null<initializer*> child;
    gui::widgets::search popup_search = gui::widgets::search("frames::binder::popup_search");
    widgets::submenu submenu = widgets::submenu("Биндер##frames::binder");
    widgets::binder_variables_popup popup;

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    static auto get_binds() -> nlohmann::json&;
    static auto generate_uuid() -> std::string;
    static auto hotkey_callback(hotkey& hotkey) -> void;

    auto add_hotkey(const std::string_view& uuid) const -> void;
    auto render_editable_title(std::string& label, std::string& value) const -> void;
    auto render_hotkey(const std::string_view& uuid, float width) const -> void;

    auto on_entry_destroyed(std::size_t index) const -> void;
    auto frame_renderer(std::string& label, std::any& payload) -> void;
    auto add_callback() -> void;

    auto on_send_command(const samp::out_event<samp::event_id::send_command>& event) const -> bool;
public:
    auto render() -> void override;
    auto on_event(const samp::event_info& event) -> bool override;

    /// Construct the frame.
    ///
    /// @param child[in] Valid pointer to the main window.
    explicit binder(types::not_null<initializer*> child);
}; // class binder final : public basic_frame

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_BINDER_H
