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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_GAME_PAD_H
#define GADMIN_PLUGIN_GAME_PAD_H

#include "plugin/types/address.h"

namespace plugin::game {

/// Provides methods for managing game pad controls.
class pad final {
private:
    static inline types::address<std::uintptr_t> instance = 0xB73458;
    static inline types::offset<bool> disable_player_controls_offset = 0x10E;
    static inline types::offset<bool> disable_player_enter_vehicle_offset = 0x119;
public:
    /// Disable player control.
    static auto disable_player_control() noexcept -> void;

    /// Set the player's ability to enter a vehicle.
    /// 
    /// @param state[in] The state to set for player's ability to enter a vehicle.
    static auto set_player_enter_vehicle(bool state) noexcept -> void;
}; // class pad final

} // namespace plugin::game

#endif // GADMIN_PLUGIN_GAME_PAD_H
