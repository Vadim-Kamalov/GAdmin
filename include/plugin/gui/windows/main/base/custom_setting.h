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

/// @file plugin/gui/windows/main/base/custom_setting.h
/// @brief Defines the base class for custom settings in the GUI.

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_CUSTOM_SETTING_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_CUSTOM_SETTING_H

#include "plugin/gui/gui.h"
#include "plugin/types/simple.h"
#include <nlohmann/json.hpp>
#include <memory>

namespace plugin::gui::windows::main {

/// @class basic_custom_setting
/// @brief Base class for custom settings.
class basic_custom_setting {
public:
    /// @brief virtual destructor.
    virtual ~basic_custom_setting() = default;

    /// @brief Gets the ID of the setting.
    /// @return The ID of the setting
    virtual auto get_id() const -> types::zstring_t = 0;

    /// @brief Renders the setting.
    /// @param gui The GUI initializer.
    /// @param setter The JSON object for setting values.
    virtual auto render(types::not_null<gui_initializer*> gui, nlohmann::json& setter) -> void = 0;
}; // class basic_custom_setting

/// @brief Unique pointer type for custom setting objects.
using custom_setting_ptr_t = std::unique_ptr<basic_custom_setting>;

} // namespace plugin::gui::windows::main

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_CUSTOM_SETTING_H
