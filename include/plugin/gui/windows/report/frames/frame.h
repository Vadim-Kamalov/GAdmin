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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_REPORT_FRAMES_FRAME_H
#define GADMIN_PLUGIN_GUI_WINDOWS_REPORT_FRAMES_FRAME_H

#include <cstdint>
#include <utility>
#include <memory>
#include "plugin/types/simple.h"
#include "plugin/types/not_null.h"
#include "plugin/samp/events/event.h"

namespace plugin::gui::windows::report {

class initializer;

/// All available frames to switch to in the report window.
enum class frame : std::uint8_t {
    current_report,   ///< Frame of the current report. Selected by default.
    previous_answers, ///< Frame of all answers registered on the session.
    user_all_answers, ///< Frame of all saved user's sent answers or closed reports.

    /// Frame for selecting the GPS path which will be inserted to the answer input.
    gps,

    /// Count of all frames. Must always be the last entry in the enumeration.
    count
}; // enum class frame : std::uint8_t

/// Count of all frames as `std::uint8_t`.
static constexpr std::uint8_t frame_count = std::to_underlying(frame::count);

/// Base class for all frames used in the report window.
class basic_frame {
protected:
    /// Valid pointer to the initializer class.
    types::not_null<initializer*> child;
public:
    virtual ~basic_frame() = default;

    /// Get the button label of the frame when the user is on /alogin.
    ///
    /// @return Button label of the frame when the user is on /alogin.
    virtual auto get_label_for_admin() const -> types::zstring_t = 0;

    /// Get the button label of the frame when the user is not on /alogin.
    ///
    /// @return Button label of the frame when the user is not on /alogin.
    virtual auto get_label_for_helper() const -> types::zstring_t = 0;

    /// Check if the frame is enabled in the configuration by the user.
    ///
    /// @return Whether the frame is enabled.
    virtual auto is_enabled() const -> bool = 0;

    /// Render the frame.
    virtual auto render() -> void = 0;

    /// Send SA:MP event to the frame.
    ///
    /// @param event[in] SA:MP event information.
    /// @return          Whether the event should continue processing.
    virtual auto on_event(const samp::event_info& event) -> bool;

    /// Construct the frame.
    ///
    /// @param child[in] Valid pointer to the initializer class.
    explicit basic_frame(types::not_null<initializer*> child)
        : child(child) {}
}; // class basic_frame

using basic_frame_ptr_t = std::unique_ptr<basic_frame>;

} // namespace plugin::gui::windows::report

#endif // GADMIN_PLUGIN_GUI_WINDOWS_REPORT_FRAMES_FRAME_H
