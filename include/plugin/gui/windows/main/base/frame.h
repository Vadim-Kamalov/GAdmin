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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_FRAME_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_FRAME_H

#include <memory>
#include "plugin/samp/events/event.h"

namespace plugin::gui::windows::main {

/// Base class for all frames used in the main window.
class basic_frame {
public:
    virtual ~basic_frame() = default;

    /// Render the frame.
    virtual auto render() -> void = 0;

    /// Process SA:MP event.
    /// 
    /// @param event[in] SA-MP event information.
    /// @return          Whether the event should continue processing.
    virtual auto on_event(const samp::event_info& event) -> bool;
}; // class basic_frame

/// RAII pointer to the frame.
using frame_ptr_t = std::unique_ptr<basic_frame>;

} // namespace plugin::gui::windows::main

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_FRAME_H
