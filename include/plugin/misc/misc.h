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

#ifndef GADMIN_PLUGIN_MISC_H
#define GADMIN_PLUGIN_MISC_H

#include "plugin/misc/base/feature.h"
#include "plugin/types/not_null.h"
#include <deque>

namespace plugin::misc {

/// Represents a handler for the miscellaneous features in the plugin.
class initializer final {
private:
    std::deque<feature_ptr_t> features;
public:
    /// Send SA:MP event to the miscellaneous features.
    ///
    /// @param event[in] SA:MP event information.
    /// @return          Whether the event should continue processing.
    auto on_event(const samp::event_info& event) -> bool;

    /// Send window's message to the miscellaneous features.
    ///
    /// @param message[in]            Message ID.
    /// @param wparam[in], lparam[in] Message parameters.
    /// @return                       Whether the message should continue processing.
    auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool;

    /// Send information to the miscellaneous features that user's `/alogin` state is changed.
    ///
    /// @param state[in] New `/alogin` state.
    auto on_alogin_new_state(bool state) -> void;

    /// Render features' specific GUI elements. Must be called each frame.
    auto render(types::not_null<gui_initializer*> child) -> void;

    /// Main loop for all miscellaneous features.
    auto main_loop() -> void;

    /// Send information to the miscellaneous features that SA:MP is fully initialized.
    auto on_samp_initialize() -> void;

    /// Constuct the handler.
    explicit initializer();
}; // class initializer final

} // namespace plugin::misc

#endif // GADMIN_PLUGIN_MISC_H
