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

#ifndef GADMIN_PLUGIN_GAME_CURSOR_H
#define GADMIN_PLUGIN_GAME_CURSOR_H

namespace plugin {
namespace signatures {

using clear_mouse_history_t = void(__cdecl*)();
using update_pads_t = void(__cdecl*)();

} // namespace signatures

namespace game {

/// Provides method for changing cursor visibility state.
class cursor final {
public:
    /// Set visibility state for the cursor.
    /// 
    /// @param state[in] Whether to show or hide cursor.
    static auto set_state(bool state) noexcept -> void;
}; // class cursor final

} // namespace game
} // namespace plugin

#endif // GADMIN_PLUGIN_GAME_CURSOR_H
