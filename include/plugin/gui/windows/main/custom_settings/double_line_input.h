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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_DOUBLE_LINE_INPUT_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_DOUBLE_LINE_INPUT_H

#include "plugin/gui/windows/main/base/custom_setting.h"

namespace plugin::gui::windows::main::custom_settings {

/// Custom settings for objects that utilize an array of string pairs, e.g.,
///
/// ```jsonc
/// [
///     { "a": "value", "b": "value" },
///     { "a": "value", "b": "value" },
///     // ...
/// ]
/// ```
///
/// Renders two `ImGui::InputText` fields on the same line for
/// each object in the array, enabling their configuration.
class double_line_input : public basic_custom_setting {
private:
    static constexpr float placeholder_font_size = 16;
    std::pair<std::string, std::string> keys, placeholders;
public:
    auto render(types::not_null<gui_initializer*> gui, nlohmann::json& setter) -> void override;
    
    /// Construct setting.
    ///
    /// @param keys[in]         Keys for the string pairs.
    /// @param placeholders[in] Placeholders for the input fields.
    explicit double_line_input(const std::pair<std::string, std::string>& keys,
                               const std::pair<std::string, std::string>& placeholders)
        : keys(std::move(keys)), placeholders(std::move(placeholders)) {}
}; // class double_line_input : public basic_custom_setting

} // namespace plugin::gui::windows::main::custom_settings

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_DOUBLE_LINE_INPUT_H
