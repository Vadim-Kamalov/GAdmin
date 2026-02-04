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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_MESSAGE_RECOLORER_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_MESSAGE_RECOLORER_H

#include "plugin/gui/windows/main/base/custom_setting.h"

namespace plugin::gui::windows::main::custom_settings {

/// Custom setting for the message recolorer. Allows the user
/// to select a specific message, change its color, or disable
/// recoloring for only that message.
class message_recolorer final : public basic_custom_setting {
private:
    static constexpr std::uint8_t color_input_buffer_size = 7 /* "RRGGBB\0" */;
    static constexpr std::uint8_t count_of_lines_in_group = 3;
    static constexpr float color_edit_height_width = 150.0f;

    ImVec4 color_picker_buffer;
    std::string color_input_buffer;
    std::size_t selected_item_index = 0;

    auto horizontal_align_group() const -> void;
    auto render_select_buttons(nlohmann::json& setter) -> void;
    auto render_color_edit(nlohmann::json& setter) -> void;
    auto render_color_input(types::not_null<gui_initializer*> gui, nlohmann::json& setter,
                            float start, float width) -> void;
public:
    inline auto get_id() const -> types::zstring_t override;
    auto render(types::not_null<gui_initializer*> gui, nlohmann::json& setter) -> void override;
    explicit message_recolorer();
}; // class message_recolorer final : public basic_custom_setting

} // namespace plugin::gui::windows::main::custom_settings

inline auto plugin::gui::windows::main::custom_settings::message_recolorer::get_id() const
    -> types::zstring_t
{
    return "message_recolorer.items";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_MESSAGE_RECOLORER_H
