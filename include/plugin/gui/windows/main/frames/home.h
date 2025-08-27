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
/// @file plugin/gui/windows/main/frames/home.h
/// @brief Defines the home frame in the GUI.

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_HOME_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_HOME_H

#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/types/not_null.h"

namespace plugin::gui::windows::main::frames {

class home final : public basic_frame {
public:

    /// @class home
    /// @brief Represents the home frame in the GUI.
    types::not_null<initializer*> child;

    /// @brief Renders the home frame.
    auto render() -> void override;

    /// @brief Constructor for the home frame.
    /// @param child The GUI initializer.
    explicit home(types::not_null<initializer*> child)
        : child(child) {}
}; // class home final

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_HOME_H
