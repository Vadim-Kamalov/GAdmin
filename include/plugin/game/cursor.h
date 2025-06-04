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
/// @file include/plugin/game/cursor.h
/// @details Provides functionality for managing the in-game cursor.

#ifndef GADMIN_PLUGIN_GAME_CURSOR_H
#define GADMIN_PLUGIN_GAME_CURSOR_H

namespace plugin {
namespace signatures {

/// @brief Function pointer type for clearing mouse history.
using clear_mouse_history_t = void(__cdecl*)();

/// @brief Function pointer type for updating pads.
using update_pads_t = void(__cdecl*)();

} // namespace signatures

namespace game {

/// @class cursor
/// @brief Manages in-game cursor's state.
class cursor final {
public:
    /// @brief Sets the status of the cursor.
    /// @param status The status to set for the cursor.
    static auto set_status(bool status) noexcept -> void;
}; // class cursor final

} // namespace game
} // namespace plugin

#endif // GADMIN_PLUGIN_GAME_CURSOR_H
