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
/// @file include/plugin/cheats/tracers.h
/// @details Provides functionality for managing bullet tracers in the game.

#ifndef GADMIN_PLUGIN_CHEATS_TRACERS_H
#define GADMIN_PLUGIN_CHEATS_TRACERS_H

#include "plugin/cheats/base.h"
#include "plugin/types/simple.h"
#include <chrono>
#include <deque>

namespace plugin::cheats {

/// @class tracers
/// @brief Implements bullet tracer functionality
/// @inherits basic_cheat
class tracers final : public basic_cheat {
private:
    /// @struct tracer_information
    /// @brief Contains information about a bullet tracer
    struct tracer_information {
        bool miss; ///< Flag indicating if the bullet missed
        types::vector_3d origin; ///< Origin coordinates of the tracer
        types::vector_3d target; ///< Target coordinates of the tracer
        std::chrono::steady_clock::time_point time; ///< Time point of the trace
    }; // struct tracer_information

    gui::hotkey hotkey;
    std::deque<tracer_information> current_tracers;

    auto hotkey_callback(gui::hotkey& hotkey) -> void;

    /// @brief Handles bullet synchronization events
    /// @param synchronization The bullet synchronization packet
    /// @return Boolean indicating if the event was handled
    auto on_bullet_synchronization(const samp::packet<samp::event_id::bullet_synchronization>& synchronization) -> bool;
public:
    /// @brief Handles events related to tracers
    /// @param event The event information
    /// @return Boolean indicating if the event was handled
    /// @override
    auto on_event(const samp::event_info& event) -> bool override;

    /// @brief Renders the tracers interface
    /// @param child Pointer to the GUI initializer
    /// @override
    auto render(types::not_null<gui_initializer*> child) -> void override;

    /// @brief Registers hotkeys for tracer functionality
    /// @param handler Pointer to the hotkey handler
    /// @override
    auto register_hotkeys(types::not_null<gui::hotkey_handler*> handler) -> void override;

    explicit tracers();
}; // class tracers final : public basic_cheat

} // namespace plugin::cheats

#endif // GADMIN_PLUGIN_CHEATS_TRACERS_H
