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
    static constexpr float max_render_distance = 0x7D0;
    static inline bool cheat_active = false;

    gui::hotkey hotkey;

    auto hotkey_callback(gui::hotkey& hotkey) -> void;
public:
    /// Enable wallhack.
    static auto enable() -> void;
    
    /// Disable wallhack.
    static auto disable() -> void;
    
    /// Switch wallhack with depending on the passed state.
    ///
    /// @param when[in] Pass true to enable, false to disable.
    static auto toggle(bool when) -> void;

    /// Update states of the wallhack renderers (custom render,
    /// SA:MP render) based on the current cheat configuration.
    static auto update() -> void;

    auto register_hotkeys(types::not_null<gui::hotkey_handler*> handler) -> void override;
    auto render(types::not_null<gui_initializer*> child) -> void override;
    auto on_alogin_new_state(bool state) -> void override;

    explicit wallhack();
}; // class wallhack final : public basic_cheat

} // namespace plugin::cheats

#endif // GADMIN_PLUGIN_CHEATS_WALLHACK_H
