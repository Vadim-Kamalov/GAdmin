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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_CUSTOM_SETTING_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_CUSTOM_SETTING_H

#include "plugin/gui/gui.h"
#include "plugin/types/simple.h"
#include <nlohmann/json.hpp>
#include <memory>

namespace plugin::gui::windows::main {

/// Base class for custom settings.
///
/// In the main window, custom settings are used when the default methods are
/// insufficient for configuring a specific object. A custom setting must handle
/// both the rendering and configuration of the object passed to it.
///
/// @note ID of the custom setting must follow the format:
///       `<subsection_key>.<setting_key>`, e.g., `report.insert_buttons`.
class basic_custom_setting {
public:
    virtual ~basic_custom_setting() = default;

    /// Get the ID of the setting in `<subsection_key>.<setting_key>` format.
    ///
    /// @return ID of the setting
    virtual auto get_id() const -> types::zstring_t = 0;

    /// Render the setting.
    /// 
    /// @param gui[in]     Valid instance of the GUI initializer used to create window.
    /// @param setter[out] JSON object for setting values.
    virtual auto render(types::not_null<gui_initializer*> gui, nlohmann::json& setter) -> void = 0;
}; // class basic_custom_setting

/// RAII pointer to the custom setting.
using custom_setting_ptr_t = std::unique_ptr<basic_custom_setting>;

} // namespace plugin::gui::windows::main

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_CUSTOM_SETTING_H
