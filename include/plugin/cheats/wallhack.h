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
/// @file include/plugin/cheats/wallhack.h
/// @details Provides functionality for the wallhack cheat, allowing visibility through walls.
///

#ifndef GADMIN_PLUGIN_CHEATS_WALLHACK_H
#define GADMIN_PLUGIN_CHEATS_WALLHACK_H

#include "plugin/cheats/base.h"

namespace plugin::cheats {

/// @class wallhack
/// @brief Implements wallhack cheat functionality
/// @inherits basic_cheat
class wallhack : public basic_cheat {
private:
    gui::hotkey hotkey;
    bool cheat_active = false;

    /// @brief Sets the state of the wallhack cheat
    /// @param state Boolean state to set the wallhack to
    void set_wallhack_state(bool state);

    /// @brief Callback for hotkey activation
    /// @param hotkey Reference to the triggering hotkey
    void hotkey_callback(gui::hotkey& hotkey);
public:
    /// @brief Registers hotkeys for wallhack functionality
    /// @param handler Pointer to the hotkey handler
    /// @override
    void register_hotkeys(types::not_null<gui::hotkey_handler*> handler) override;

    /// @brief Renders the wallhack interface
    /// @param child Pointer to the GUI initializer
    /// @override
    void render(types::not_null<gui_initializer*> child) override;

    /// @brief Handles login state changes
    /// @param state New login state (true = logged in)
    /// @override
    void on_alogin_new_state(bool state) override;

    explicit wallhack();
private:
    static constexpr float render_distance = 0x7D0; ///< Maximum render distance for wallhack
}; // class wallhack : public basic_cheat

} // namespace plugin::cheats

#endif // GADMIN_PLUGIN_CHEATS_WALLHACK_H
