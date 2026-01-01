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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_CHEATS_TRACERS_H
#define GADMIN_PLUGIN_CHEATS_TRACERS_H

#include "plugin/cheats/base.h"
#include "plugin/types/simple.h"
#include <chrono>
#include <deque>

namespace plugin::cheats {

/// Cheat for bullet tracing functionality.
///
/// Renders all bullets' trajectories and whether they hit the target.
/// Maximum amount of tracers is limited, and their rendering conditions
/// can be configured by the user.
///
/// Only functions when the user is authenticated via `/alogin` and the
/// cheat is enabled in the configuration.
class tracers final : public basic_cheat {
private:
    struct tracer_information final {
        bool miss;
        types::vector_3d origin;
        types::vector_3d target;
        std::chrono::steady_clock::time_point time;
    }; // struct tracer_information final

    gui::hotkey hotkey;
    std::deque<tracer_information> current_tracers;

    auto hotkey_callback(gui::hotkey& hotkey) -> void;
    auto on_bullet_synchronization(const samp::packet<samp::event_id::bullet_synchronization>& synchronization) -> bool;
public:
    auto on_event(const samp::event_info& event) -> bool override;
    auto render(types::not_null<gui_initializer*> child) -> void override;
    auto register_hotkeys(types::not_null<gui::hotkey_handler*> handler) -> void override;

    explicit tracers();
}; // class tracers final : public basic_cheat

} // namespace plugin::cheats

#endif // GADMIN_PLUGIN_CHEATS_TRACERS_H
