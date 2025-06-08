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
/// @file include/plugin/game.h
/// @details Provides general game-related utilities and functions.

#ifndef GADMIN_PLUGIN_GAME_H
#define GADMIN_PLUGIN_GAME_H

#include "plugin/types/simple.h"
#include <utility>
#include <windef.h>

namespace plugin {
namespace signatures {

/// @brief Function pointer type for calculating screen coordinates.
using calc_screen_coords = bool(__cdecl*)(types::vector_3d*, types::vector_3d*);

} // namespace signatures

namespace game {

/// @brief Gets the window handle of the game.
/// @return The window handle
inline auto get_window() noexcept -> HWND;

/// @brief Gets the device associated with the game.
/// @return The device identifier.
inline auto get_device() noexcept -> DWORD;

/// @brief Checks if the game menu is opened.
/// @return True if the menu is opened, false otherwise.
inline auto is_menu_opened() noexcept -> bool;

/// @brief Gets the screen resolution of the game.
/// @return A pair representing the screen resolution (width, height).
auto get_screen_resolution() noexcept -> std::pair<float, float>;

/// @brief Converts 3D coordinates to screen coordinates.
/// @note If the Z-coordinate returns a value below `0.0f`, then the conversion has failed.
/// @param coords The 3D coordinates to convert.
/// @return The corresponding screen coordinates.
auto convert_3d_coords_to_screen(const types::vector_3d& coords) noexcept -> types::vector_3d;

} // namespace game
} // namespace plugin

inline auto plugin::game::get_window() noexcept -> HWND {
    return **reinterpret_cast<HWND**>(0xC17054);
}

inline auto plugin::game::get_device() noexcept -> DWORD {
    return *reinterpret_cast<DWORD*>(0xC97C28);
}

inline auto plugin::game::is_menu_opened() noexcept -> bool {
    return *reinterpret_cast<bool*>(0xBA67A4);
}

#endif // GADMIN_PLUGIN_GAME_H
