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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_CUSTOM_SETTINGS_SPECTATOR_ACTIONS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_CUSTOM_SETTINGS_SPECTATOR_ACTIONS_H

#include "plugin/gui/windows/main/base/custom_setting.h"

namespace plugin::gui::windows::main::custom_settings {

/// Custom setting for action buttons in spectator mode.
///
/// This implementation allows any button to be disabled or configured to either
/// evaluate a binder string, or execute a provided action. The rendering order
/// of the buttons can also be adjusted by moving them up or down.
class spectator_actions final : public basic_custom_setting {
private:
    static constexpr types::zstring_t action_selector_placeholders[2] = {
        "Отправка или вставка текст в чат",
        "Функциональное"
    }; // static constexpr types::zstring_t action_selector_placeholders[2]
    
    static constexpr float button_width = 100;
    static constexpr float button_border_size = 1;
    static constexpr float button_count_on_line = 3;

    std::size_t selected_index = 0;
    bool selected_action_from_menu = false;

    auto render_lines(float width, nlohmann::json& setter) -> void;
public:
    inline auto get_id() const -> types::zstring_t override;
    auto render(types::not_null<gui_initializer*> gui, nlohmann::json& setter) -> void override;
}; // class spectator_actions final : public basic_custom_setting

} // namespace plugin::gui::windows::main::custom_settings

inline auto plugin::gui::windows::main::custom_settings::spectator_actions::get_id() const
    -> types::zstring_t
{
    return "spectator_actions.buttons";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_CUSTOM_SETTINGS_SPECTATOR_ACTIONS_H
