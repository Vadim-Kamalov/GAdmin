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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_SHORT_COMMANDS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_SHORT_COMMANDS_H

#include "plugin/gui/windows/main/custom_settings/double_line_input.h"

namespace plugin::gui::windows::main::custom_settings {

/// Custom setting for the short commands. Uses the `double_line_input`
/// class as the backend for rendering.
class short_commands final : public double_line_input {
public:
    inline auto get_id() const -> types::zstring_t override;
   
    explicit short_commands()
        : double_line_input({ "command", "replacement" },
                            { "Команда", "Замена" }) {}
}; // class short_commands final : public basic_custom_setting

} // namespace plugin::gui::windows::main::custom_settings

inline auto plugin::gui::windows::main::custom_settings::short_commands::get_id() const
    -> types::zstring_t
{
    return "short_commands.commands";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_SHORT_COMMANDS_H
