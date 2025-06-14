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
/// @file include/plugin/cheats/clickwarp.h
/// @details Provides functionality for teleporting to selected locations in the game.

#ifndef GADMIN_PLUGIN_CHEATS_CLICKWARP_H
#define GADMIN_PLUGIN_CHEATS_CLICKWARP_H

#include "plugin/cheats/base.h"
#include "plugin/game/vehicle.h"
#include "plugin/types/simple.h"

namespace plugin::cheats {

/// @class clickwarp
/// @brief Implements teleportation cheat by clicking on a map location
/// @inherits basic_cheat
class clickwarp final : public basic_cheat {
private:
    static constexpr float font_size = 18;

    struct teleport_information_t {
        types::vector_3d coordinates;
        game::vehicle vehicle_to_jump;
    }; // struct teleport_information_t

    bool selecting_place_to_warp = false;
    bool need_to_update_cursor = false;

    std::optional<teleport_information_t> teleport_information;

    auto stop_selecting_place() -> void;
public:
    /// @brief Handles login state changes
    /// @param state New login state (true = logged in)
    /// @override
    auto on_alogin_new_state(bool state) -> void override;

    /// @brief Handles events for teleportation
    /// @param message The message code
    /// @param wparam Additional message information
    /// @param lparam Additional message information
    /// @return Boolean indicating if the event was handled
    /// @override 
    auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool override;

    /// @brief Renders the teleportation interface
    /// @param child Pointer to the GUI initializer
    /// @override
    auto render(types::not_null<gui_initializer*> child) -> void override;
}; // class clickwarp final : public basic_cheat

} // namespace plugin::cheats

#endif // GADMIN_PLUGIN_CHEATS_CLICKWARP_H
