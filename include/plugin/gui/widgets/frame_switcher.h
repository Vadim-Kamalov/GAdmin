/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2024-2025 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only
///
/// @file include/plugin/gui/widgets/frame_switcher.h
/// @details Provides functionality for switching frames in the GUI.

#ifndef GADMIN_PLUGIN_GUI_WIDGETS_FRAME_SWITCHER_H
#define GADMIN_PLUGIN_GUI_WIDGETS_FRAME_SWITCHER_H

#include "plugin/gui/windows/main.h"
#include "plugin/types/not_null.h"

namespace plugin::gui::widgets {

/// @brief Switches the frame in the GUI.
/// @param frame The frame to switch to.
/// @param child The child window to apply the frame to.
void frame_switcher(const windows::main::frame& frame, types::not_null<windows::main*> child);

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_FRAME_SWITCHER_H
