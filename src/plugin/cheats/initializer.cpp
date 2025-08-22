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

/// @brief Implements the cheat initializer functionality

#include "plugin/cheats/initializer.h"
#include "plugin/cheats/airbreak.h"
#include "plugin/cheats/clickwarp.h"
#include "plugin/cheats/tracers.h"
#include "plugin/cheats/wallhack.h"
#include "plugin/gui/gui.h"
#include <memory>

/// @brief Constructor for the cheat initializer.
/// @param gui The GUI initializer.
plugin::cheats::initializer::initializer(types::not_null<gui_initializer*> gui) : gui(gui) {
    cheats.push_back(std::make_unique<airbreak>());
    cheats.push_back(std::make_unique<wallhack>());
    cheats.push_back(std::make_unique<clickwarp>());
    cheats.push_back(std::make_unique<tracers>());

    for (const auto& cheat : cheats)
        cheat->register_hotkeys(gui->hotkey_handler.get());
}

/// @brief Main loop for the cheat initializer.
auto plugin::cheats::initializer::main_loop() -> void {
    for (const auto& cheat : cheats)
        cheat->main_loop();
}

/// @brief Renders the cheats.
auto plugin::cheats::initializer::render() -> void {
    for (const auto& cheat : cheats)
        cheat->render(gui);
}

/// @brief Handles login state changes for the cheat initializer.
/// @param state The new login state.
auto plugin::cheats::initializer::on_alogin_new_state(bool state) -> void {
    for (const auto& cheat : cheats)
        cheat->on_alogin_new_state(state);
}

/// @brief Handles SA-MP events for the cheat initializer.
/// @param event The SA-MP event information.
/// @return True if the event was handled, false otherwise.
auto plugin::cheats::initializer::on_event(const samp::event_info& event) -> bool {
    for (const auto& cheat : cheats) {
        event.stream->reset_read_pointer();
        if (!cheat->on_event(event))
            return false;
    }

    return true;
}

/// @brief Handles system events for the cheat initializer.
/// @param message The message code.
/// @param wparam Additional message information.
/// @return True if the event was handled, false otherwise.
auto plugin::cheats::initializer::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool {
    for (const auto& cheat : cheats)
        if (!cheat->on_event(message, wparam, lparam))
            return false;
    
    return true;
}
