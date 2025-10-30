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

#ifndef GADMIN_PLUGIN_SAMP_CORE_SERVER_SETTINGS_H
#define GADMIN_PLUGIN_SAMP_CORE_SERVER_SETTINGS_H

#include "plugin/types/address.h"

namespace plugin::samp {

/// Represents methods for managing server's settings on the user side.
class server_settings final {
private:
    types::dynamic_address<std::uintptr_t> pointer;

    static inline types::offset<float> name_tags_render_distance_offset = 0x27;
    static inline types::offset<bool> name_tags_render_behind_wall_offset = 0x2F;
    static inline types::offset<bool> name_tags_render_state = 0x38;
public:
    /// Get distance of the name tags' render.
    /// 
    /// @return Distance of the name tags' render.
    auto get_name_tags_render_distance() const -> float;

    /// Set distance of the name tags' render.
    ///
    /// @param distance[in] New distance of the name tags' render.
    auto set_name_tags_render_distance(float distance) const -> void;
    
    /// Allow name tags' to be rendered behing the walls.
    ///
    /// @param state[in] New state of name tags' rendering behind the walls.
    auto set_name_tags_render_behind_wall(bool state) const -> void;

    /// Set name tags' render state.
    ///
    /// @param state[in] New state of name tags' rendering.
    auto set_name_tags_render_state(bool state) const -> void;

    /// Construct the server's settings SA:MP class.
    ///
    /// @param pointer[in] Pointer to the server's settings SA:MP class.
    explicit server_settings(const types::dynamic_address<std::uintptr_t>& pointer)
        : pointer(pointer) {}
}; // class server_settings final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_SERVER_SETTINGS_H
