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

/// @file plugin/gui/windows/main/base/frame.h
/// @brief Defines the base class for frames in the GUI.

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_FRAME_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_FRAME_H

#include <memory>
#include "plugin/samp/events/event.h"

namespace plugin::gui::windows::main {

/// @class basic_frame
/// @brief Base class for frames.
class basic_frame {
public:
    virtual ~basic_frame() = default;

    /// @brief Renders the frame.
    virtual auto render() -> void = 0;

    /// @brief Handles events.
    /// @param event The event information.
    /// @return True if the event was handled
    virtual auto on_event(const samp::event_info& event) -> bool;
}; // class basic_frame

/// @brief unique pointer type for frame objects
using frame_ptr_t = std::unique_ptr<basic_frame>;

} // namespace plugin::gui::windows::main

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_FRAME_H
