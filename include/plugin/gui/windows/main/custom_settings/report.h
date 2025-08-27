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

/// @file plugin/gui/windows/main/custom_settings/report.h
/// @brief Defines a custom setting for report buttons in the GUI.

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_REPORT_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_REPORT_H

#include "plugin/gui/windows/main/custom_settings/double_line_input.h"

namespace plugin::gui::windows::main::custom_settings {

/// @class report
/// @brief Custom setting for report buttons.
class report final : public double_line_input {
public:
    /// @brief Gets the ID of the setting.
    /// @return The ID of the setting
    inline auto get_id() const -> types::zstring_t override;

    explicit report()
        : double_line_input({ "name", "insert" },
                            { "Название кнопки", "Текст для вставки" }) {}
}; // class report final : public basic_custom_setting

} // namespace plugin::gui::windows::main::custom_settings

/// @brief Gets the ID of the report setting.
/// @return The ID of the report setting.
inline auto plugin::gui::windows::main::custom_settings::report::get_id() const
    -> types::zstring_t
{
    return "report.insert_buttons";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_REPORT_H
