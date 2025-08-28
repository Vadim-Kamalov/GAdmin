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

#ifndef GADMIN_PLUGIN_CHEATS_WALLHACK_H
#define GADMIN_PLUGIN_CHEATS_WALLHACK_H

#include "plugin/cheats/base.h"

namespace plugin::cheats {

/// Cheat for wallhack functionality.
///
/// Renders nametags even if they are behind walls and extends the default
/// SA:MP render radius distance limit. Nametags can be rendered either
/// using default SA:MP methods or ImGui, which is significantly faster.
///
/// Only functions when the user is authenticated via `/alogin` and
/// the cheat is enabled in the configuration.
class wallhack final : public basic_cheat {
private:
    static constexpr float render_distance = 0x7D0;

    gui::hotkey hotkey;
    bool cheat_active = false;

    auto set_wallhack_state(bool state) -> void;
    auto hotkey_callback(gui::hotkey& hotkey) -> void;
public:
    /// Set nametags to be rendered using default SA:MP methods with extended functionality.
    ///
    /// @param state[in]              New render state.
    /// @param ensure_usage_valid[in] Whether to ensure the user is authenticated via `/alogin`
    ///                               and the cheat is enabled in the configuration.
    static auto set_samp_render_state(bool state, bool ensure_usage_valid = true) noexcept -> void;
    
    auto register_hotkeys(types::not_null<gui::hotkey_handler*> handler) -> void override;
    auto render(types::not_null<gui_initializer*> child) -> void override;
    auto on_alogin_new_state(bool state) -> void override;

    explicit wallhack();
}; // class wallhack final : public basic_cheat

} // namespace plugin::cheats

#endif // GADMIN_PLUGIN_CHEATS_WALLHACK_H
