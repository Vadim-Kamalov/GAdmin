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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only
/// 
/// @file include/plugin/cheats/base.h
/// @brief Base interface for cheat modules
/// @details Provides core interface that all cheat systems must implement:
/// - Hotkey registration
/// - Rendering
/// - Main loop processing
/// - Event handling
/// - State management
/// 

#ifndef GADMIN_PLUGIN_CHEATS_BASE_H
#define GADMIN_PLUGIN_CHEATS_BASE_H

#include "plugin/gui/hotkey.h"
#include "plugin/samp/events/event.h"
#include <memory>

namespace plugin::cheats {

/// @class basic_cheat
/// @brief Abstract base class for all cheat modules
/// @details Serves as foundation for cheat implementations, providing:
/// - Default implementations for optional functionality
/// - Consistent interface for plugin system
/// - Polymorphic behavior through virtual methods
class basic_cheat {
public:
    virtual ~basic_cheat() = default;

    /// @brief Registers hotkeys for the cheat module
    /// @param handler Pointer to hotkey handler system
    /// @note Base implementation does nothing (optional feature)
    virtual void register_hotkeys(types::not_null<gui::hotkey_handler*> handler) {}
    
    /// @brief Renders cheat-specific GUI elements
    /// @param child GUI initializer reference
    /// @note Base implementation does nothing (optional feature)
    virtual void render(types::not_null<gui_initializer*> child) {}
    virtual void main_loop() {}
    
    virtual void on_alogin_new_state(bool state) {}

    /// @brief Processes SA-MP events
    /// @param event SA-MP event information
    /// @return true if event should continue processing, false to consume it
    /// @note Base implementation allows all events through
    virtual bool on_event(const samp::event_info& event) { return true; }

    /// @brief Processes Windows messages
    /// @param message Windows message ID
    /// @param wparam Message parameter
    /// @param lparam Message parameter
    /// @return true if message should continue processing, false to consume it
    /// @note Base implementation allows all messages through
    virtual bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam) { return true; }
}; // class basic_cheat

/// @brief Alias for cheat pointer type
/// @details std::unique_ptr to basic_cheat for memory management
using cheat_t = std::unique_ptr<basic_cheat>;

} // namespace plugin::cheats

#endif // GADMIN_PLUGIN_CHEATS_BASE_H
