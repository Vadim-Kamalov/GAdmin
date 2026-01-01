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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_CHEATS_BASE_H
#define GADMIN_PLUGIN_CHEATS_BASE_H

#include "plugin/gui/hotkey.h"
#include "plugin/samp/events/event.h"
#include <memory>

namespace plugin::cheats {

/// Base class for all cheat modules.
///
/// Serves as the base class for all cheat implementations, enabling:
///     
///     - Hotkey registration,
///     - Background rendering,
///     - SA:MP event handling,
///     - Window's messages processing,
///     - User authorization state management via `/alogin`.
///
/// Implementations must verify the user's `/alogin` state and check
/// if the cheat is enabled in the configuration.
class basic_cheat {
public:
    virtual ~basic_cheat() = default;

    /// Register any hotkeys used in the cheat.
    /// 
    /// @param handler[in] Pointer to the hotkey handler.
    virtual auto register_hotkeys(types::not_null<gui::hotkey_handler*> handler) -> void {}

    /// Render cheat-specific GUI elements. Must be called each frame.
    /// 
    /// @param child[in] Valid GUI initializer pointer.
    virtual auto render(types::not_null<gui_initializer*> child) -> void {}
    
    /// Main loop for the cheat.
    virtual auto main_loop() -> void {}

    /// Process user's new state of the `/alogin`.
    ///
    /// @param state[in] New user's state of the /alogin.
    virtual auto on_alogin_new_state(bool state) -> void {}

    /// Process SA:MP event.
    /// 
    /// @param event[in] SA-MP event information.
    /// @return          Whether the event should continue processing.
    virtual auto on_event(const samp::event_info& event) -> bool { return true; }

    /// Process window's message.
    ///
    /// @param message[in]            Message ID.
    /// @param wparam[in], lparam[in] Message parameters.
    /// @return                       Whether the message should continue processing.
    virtual auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool { return true; }
}; // class basic_cheat

/// RAII pointer to the cheat.
using cheat_t = std::unique_ptr<basic_cheat>;

} // namespace plugin::cheats

#endif // GADMIN_PLUGIN_CHEATS_BASE_H
