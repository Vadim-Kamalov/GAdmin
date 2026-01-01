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

#ifndef GADMIN_PLUGIN_CHEATS_LOADER_H
#define GADMIN_PLUGIN_CHEATS_LOADER_H

#include "plugin/cheats/base.h"
#include "plugin/gui/hotkey.h"
#include <deque>

namespace plugin::cheats {

/// Manages initialization and execution of cheat modules.
class initializer final {
private:
    types::not_null<gui_initializer*> gui;
    std::deque<cheat_t> cheats;
public:
    /// Main loop for all cheat modules.
    auto main_loop() -> void;

    /// Render cheats' specific GUI elements. Must be called each frame.
    auto render() -> void;

    /// Send information to the cheat modules that user's `/alogin` state is changed.
    ///
    /// @param state[in] New `/alogin` state.
    auto on_alogin_new_state(bool state) -> void;

    /// Send SA:MP event to the cheat modules.
    ///
    /// @param event[in] SA:MP event information.
    /// @return          Whether the event should continue processing.
    auto on_event(const samp::event_info& event) -> bool;

    /// Send window's message to the cheat modules.
    ///
    /// @param message[in]            Message ID.
    /// @param wparam[in], lparam[in] Message parameters.
    /// @return                       Whether the message should continue processing.
    auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool;

    /// Construct all cheat modules and register their hotkeys.
    ///
    /// @param gui[in] Valid GUI initializer pointer.
    explicit initializer(types::not_null<gui_initializer*> gui);
}; // class initializer final

} // namespace plugin::cheats

#endif // GADMIN_PLUGIN_CHEATS_LOADER_H
