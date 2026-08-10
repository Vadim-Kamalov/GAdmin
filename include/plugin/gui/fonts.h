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

#ifndef GADMIN_PLUGIN_GUI_FONTS_H
#define GADMIN_PLUGIN_GUI_FONTS_H

#include "plugin/types/simple.h"
#include <filesystem>
#include <queue>
#include <thread>
#include <imgui.h>

namespace plugin::gui {

/// Manages font initialization and loading for GUI system.
class fonts_initializer final {
private:
    static constexpr float default_font_size = 18.0f;
public:
    ImFont* regular = nullptr; ///< Regular font.
    ImFont* bold = nullptr;    ///< Bold font.
    ImFont* light = nullptr;   ///< Light font.
    ImFont* icon = nullptr;    ///< Icon font.

    /// Assign values to the fonts (`regular`, `bold`, `light` and `icon`).
    auto assign_fonts() -> void;
}; // class fonts_initializer final

} // namespace plugin::gui

#endif // GADMIN_PLUGIN_GUI_FONTS_H
