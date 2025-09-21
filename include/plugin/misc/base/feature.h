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

#ifndef GADMIN_PLUGIN_MISC_BASE_FEATURE_H
#define GADMIN_PLUGIN_MISC_BASE_FEATURE_H

#include "plugin/gui/gui.h"
#include "plugin/samp/events/event.h"
#include <memory>

namespace plugin::misc {

/// Base class for the miscellaneous features in the plugin. Serves as the
/// foundation for miscellaneous features in the plugin, enabling rendering,
/// SA:MP event and window's messages handling.
class feature {
public:
    virtual ~feature() = default;
    
    /// Process SA:MP event.
    /// 
    /// @param event[in] SA-MP event information.
    /// @return          Whether the event should continue processing.
    virtual auto on_event(const samp::event_info& event) -> bool;

    /// Process window's message.
    ///
    /// @param message[in]            Message ID.
    /// @param wparam[in], lparam[in] Message parameters.
    /// @return                       Whether the message should continue processing.
    virtual auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool;

    /// Process user's new state of the `/alogin`.
    ///
    /// @param state[in] New user's state of the /alogin.
    virtual auto on_alogin_new_state(bool state) -> void;
    
    /// Render feature-specific GUI elements. Must be called each frame.
    ///
    /// @param child[in] Valid GUI initializer pointer.
    virtual auto render(types::not_null<gui_initializer*> child) -> void;

    /// Process SA:MP initializing. Can be called only once since the plugin initialization.
    virtual auto on_samp_initialize() -> void;
    
    /// Main loop for the feature.
    virtual auto main_loop() -> void;
}; // class feature

/// RAII pointer to the miscellaneous feature.
using feature_ptr_t = std::unique_ptr<feature>;

} // namespace plugin::misc

#endif // GADMIN_PLUGIN_MISC_BASE_FEATURE_H
