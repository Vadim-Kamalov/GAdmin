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

/// @file include/plugin/gui/widgets/joystick.h
/// @details Provides functionality for managing a GUI joystick.

#ifndef GADMIN_PLUGIN_GUI_WIDGETS_JOYSTICK_H
#define GADMIN_PLUGIN_GUI_WIDGETS_JOYSTICK_H

#include <chrono>
#include <imgui.h>

namespace plugin::gui::widgets {

/// @class joystick
/// @brief Represents a GUI joystick.
class joystick {
private:
    static constexpr std::uint8_t radius = 37;
    static constexpr std::uint8_t dot_radius = 10;

    ImVec2 current, old;
    std::chrono::steady_clock::time_point time;
public:
/// @brief Updates the joystick position.
/// @param x The x-coordinate of the joystick.
/// @param y The y-coordinate of the joystick
    void update(std::uint16_t x, std::uint16_t y);

/// @brief Renders the joystick.
    void render() const;
}; // class joystick

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_JOYSTICK_H
