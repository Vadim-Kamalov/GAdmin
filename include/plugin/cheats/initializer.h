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

/// @file include/plugin/cheats/initializer.h
/// @details Provides functionality for initializing and managing cheats in the plugin.

#ifndef GADMIN_PLUGIN_CHEATS_LOADER_H
#define GADMIN_PLUGIN_CHEATS_LOADER_H

#include "plugin/cheats/base.h"
#include "plugin/gui/hotkey.h"
#include <deque>

namespace plugin::cheats {
    /// @class initializer
    /// @brief Manages initialization and execution of cheat
class initializer {
private:
    types::not_null<gui_initializer*> gui;
    std::deque<cheat_t> cheats;
public:
    void main_loop();
    void render();

    void on_alogin_new_state(bool state);
    /// @brief Handles events related to cheats
    /// @param event The event information
    /// @return Boolean indicating if the event was handled
    bool on_event(const samp::event_info& event);
    /// @brief Handles system events
    /// @param message The message code
    /// @param wparam Additional message information
    /// @param lparam Additional message information
    /// @return Boolean indicating if the event was handled
    bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam);

    /// @brief Constructor for the initializer
    /// @param gui Pointer to the GUI initializer
    explicit initializer(types::not_null<gui_initializer*> gui);
}; // class initializer

} // namespace plugin::cheats

#endif // GADMIN_PLUGIN_CHEATS_LOADER_H
