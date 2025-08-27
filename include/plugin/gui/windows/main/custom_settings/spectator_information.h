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

/// @file plugin/gui/windows/main/custom_settings/spectator_information.h
/// @brief Defines a custom setting for spectator information in the GUI.

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_SPECTATOR_INFORMATION_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_SPECTATOR_INFORMATION_H

#include "plugin/gui/windows/main/base/custom_setting.h"

namespace plugin::gui::windows::main::custom_settings {

/// @class spectator_information
/// @brief Custom setting for spectator information.
class spectator_information final : public basic_custom_setting {
private:
    static constexpr float button_width = 100;
    static constexpr float button_border_size = 1;
public:
    /// @brief Gets the ID of the setting.
    /// @return The ID of the setting.
    inline auto get_id() const -> types::zstring_t override;
    /// @brief Renders the spectator information setting.
    /// @param gui The GUI initializer.
    /// @param setter The JSON object for setting values.
    auto render(types::not_null<gui_initializer*>, nlohmann::json& setter) -> void override;
}; // class spectator_information final : public basic_custom_setting

} // namespace plugin::gui::windows::main::custom_settings

/// @brief Gets the ID of the spectator_information setting.
/// @return The ID of the spectator_information setting.
inline auto plugin::gui::windows::main::custom_settings::spectator_information::get_id() const
    -> types::zstring_t
{
    return "spectator_information.row_order";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_SPECTATOR_INFORMATION_H
