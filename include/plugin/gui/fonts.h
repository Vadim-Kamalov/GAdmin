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
    static constexpr std::uint8_t icon_font_index = 3;
    static constexpr types::zstring_t filenames[4] = {
        "notosans-regular.ttf", ///< ImFont* regular;
        "notosans-bold.ttf",    ///< ImFont* bold;
        "notosans-light.ttf",   ///< ImFont* light;
        "coolicons.ttf"         ///< ImFont* icon;
    }; // static constexpr std::string_view filenames[4]
    
    struct missing_font final {
        std::filesystem::path path;
        types::zstring_t filename;
    }; // struct missing_font final
    
    std::queue<missing_font> missing_fonts;
    std::jthread network_thread;

    auto get_missing_fonts() const -> std::queue<missing_font>;
    auto download_missing_fonts() -> void;
public:
    ImFont* regular = nullptr; ///< Regular font.
    ImFont* bold = nullptr;    ///< Bold font.
    ImFont* light = nullptr;   ///< Light font.
    ImFont* icon = nullptr;    ///< Icon font.

    /// Check if can assign fonts (`regular`, `bold`, `light` and `icon`)
    /// to their actual values from their existing/downloaded font files.
    ///
    /// @return True if can assign fonts.
    auto can_assign_fonts() const -> bool;

    /// Assign values to the fonts (`regular`, `bold`, `light` and `icon`)
    /// from their existing/downloaded font files.
    auto assign_fonts() -> void;

    /// Construct font initializer and download missing fonts.
    explicit fonts_initializer();
}; // class fonts_initializer final

} // namespace plugin::gui

#endif // GADMIN_PLUGIN_GUI_FONTS_H
