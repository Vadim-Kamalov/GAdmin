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

static inline HWND get_window() noexcept;

    /// @brief Gets the device associated with the game.
    /// @return The device identifier.

static inline DWORD get_device() noexcept;

    /// @brief Checks if the game menu is opened.
    /// @return True if the menu is opened, false otherwise.

static inline bool is_menu_opened() noexcept;

std::pair<float, float> get_screen_resolution() noexcept;

    /// @brief Gets the screen resolution of the game.
    /// @return A pair representing the screen resolution (width, height).

types::vector_3d convert_3d_coords_to_screen(const types::vector_3d& coords) noexcept;

/// @brief Converts 3D coordinates to screen coordinates.
/// @param coords The 3D coordinates to convert.
/// @return The corresponding screen coordinates.

} // namespace game
} // namespace plugin

/// @brief Gets the window handle of the game.
/// @return The window handle.

inline HWND
plugin::game::get_window() noexcept {
    return **reinterpret_cast<HWND**>(0xC17054);
}

/// @brief Gets the device associated with the game.
/// @return The device identifier.

inline DWORD
plugin::game::get_device() noexcept {
    return *reinterpret_cast<DWORD*>(0xC97C28);
}

/// @brief Checks if the game menu is opened.
/// @return True if the menu is opened, false otherwise.

inline bool
plugin::game::is_menu_opened() noexcept {
    return *reinterpret_cast<bool*>(0xBA67A4);
}

#endif // GADMIN_PLUGIN_GAME_H
