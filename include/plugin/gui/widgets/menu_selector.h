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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only
///
/// @file include/plugin/gui/widgets/menu_selector.h
/// @details Provides functionality for selecting menus in the GUI.

#ifndef GADMIN_PLUGIN_GUI_WIDGETS_MENU_SELECTOR_H
#define GADMIN_PLUGIN_GUI_WIDGETS_MENU_SELECTOR_H

#include "plugin/types/not_null.h"
#include "plugin/gui/windows/main.h"

namespace plugin::gui::widgets {

/// @brief Renders a menu selector.
/// @param child The child window to render the menu selector in
void menu_selector(types::not_null<windows::main*> child) noexcept;

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_MENU_SELECTOR_H
