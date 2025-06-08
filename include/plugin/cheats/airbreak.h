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
/// 
/// @file include/plugin/cheats/airbreak.h
/// @details Provides interface for aerial movement system allowing:

#ifndef GADMIN_PLUGIN_CHEATS_AIRBREAK_H
#define GADMIN_PLUGIN_CHEATS_AIRBREAK_H

#include "plugin/cheats/base.h"
#include "plugin/types/simple.h"
#include <numbers>

namespace plugin::cheats {

/// @class airbreak
/// @brief Implements aerial movement cheat
/// @inherits basic_cheat
class airbreak final : public basic_cheat {
private:
    gui::hotkey hotkey;
    types::vector_3d coords;
    bool cheat_active = false;
    
    auto hotkey_callback(gui::hotkey& hotkey) -> void;
    auto get_heading_from_xy(float x, float y) const -> float;
    
    static constexpr auto deg_to_rad(float deg) noexcept -> float;
public:
    /// @brief Handles login state changes
    /// @param state New login state (true = logged in)
    /// @override
    auto on_alogin_new_state(bool state) -> void override;
    auto register_hotkeys(types::not_null<gui::hotkey_handler*> handler) -> void override;
    auto main_loop() -> void override;

    explicit airbreak();
}; // class airbreak final : public basic_cheat

} // namespace plugin::cheats

constexpr auto plugin::cheats::airbreak::deg_to_rad(float deg) noexcept -> float {
    return deg * (std::numbers::pi / 180.0f);
}

#endif // GADMIN_PLUGIN_CHEATS_AIRBREAK_H
