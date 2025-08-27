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
/// 
/// @file plugin/gui/windows/main/custom_settings/double_line_input.h
/// @brief Defines a custom setting for double line input in the GUI.

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_DOUBLE_LINE_INPUT_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_DOUBLE_LINE_INPUT_H

#include "plugin/gui/windows/main/base/custom_setting.h"

namespace plugin::gui::windows::main::custom_settings {

/// @class double_line_input
/// @brief Custom setting for double line input.
class double_line_input : public basic_custom_setting {
private:
    static constexpr float placeholder_font_size = 16;
    std::pair<std::string, std::string> keys, placeholders;
public:
    /// @brief Renders the double line input.
    /// @param gui The GUI initializer.
    /// @param setter The JSON object for setting values.
    auto render(types::not_null<gui_initializer*> gui, nlohmann::json& setter) -> void override;
    
    /// @brief Constructor for double_line_input.
    /// @param keys The keys for the input fields.
    /// @param placeholders The placeholders for the input fields.
    explicit double_line_input(const std::pair<std::string, std::string>& keys,
                               const std::pair<std::string, std::string>& placeholders)
        : keys(std::move(keys)), placeholders(std::move(placeholders)) {}
}; // class double_line_input final : public basic_custom_setting

} // namespace plugin::gui::windows::main::custom_settings

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_DOUBLE_LINE_INPUT_H
