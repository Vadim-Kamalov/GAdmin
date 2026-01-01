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

#ifndef GADMIN_PLUGIN_GAME_WORLD_H
#define GADMIN_PLUGIN_GAME_WORLD_H

#include "plugin/game/entity.h"
#include "plugin/types/address.h"
#include "plugin/types/options.h"
#include "plugin/types/simple.h"
#include <optional>

namespace plugin {
namespace signatures {

using process_line_of_sight = bool(__cdecl*)(types::vector_3d*, types::vector_3d*, std::uintptr_t, std::uintptr_t*,
                                             bool, bool, bool, bool, bool, bool, bool, bool);

} // namespace signatures

namespace game {

/// Provides method to calculate line of sight in the game world.
class world final {
private:
    static inline types::address<signatures::process_line_of_sight> process_line_of_sight_address = 0x56BA00;
public:
    /// Processed line of sight.
    struct processed_line_of_sight final {
        types::vector_3d pos;       ///< Position vector of the line of sight.
        types::vector_3d normal;    ///< Normal vector of the line of sight.
        entity entity;              ///< Entity involved in the line of sight.
    }; // struct processed_line_of_sight final

    /// Conditions used while processing line of sight. Must be used only for `types::options`.
    enum class line_of_sight_condition : std::uint8_t {
        buildings = 1 << 0,     ///< Account buildings.
        vehicles = 1 << 1,      ///< Account vehicles.
        peds = 1 << 2,          ///< Account pedestrians.
        objects = 1 << 3,       ///< Account objects.
        dummies = 1 << 4,       ///< Account dummies.
        see_through = 1 << 5,   ///< Account any obstacles.
        camera_ignore = 1 << 6, ///< Account camera.
        shoot_through = 1 << 7  ///< Account any objects that can be shoot through.
    }; // enum class line_of_sight_condition : std::uint8_t

    /// Process line of sight in the game world.
    /// 
    /// @param origin[in]     Start coordinates of the line.
    /// @param target[in]     End coordinates of the line.
    /// @param conditions[in] Conditions need to account while processing line of sight.
    /// @return               Optional information of the processed line of sight.
    static auto process_line_of_sight(const types::vector_3d& origin, const types::vector_3d& target,
                                      const types::options<line_of_sight_condition>& conditions = line_of_sight_condition::buildings)
        noexcept -> std::optional<processed_line_of_sight>;
}; // class world final

} // namespace game
} // namespace plugin

#endif // GADMIN_PLUGIN_GAME_WORLD_H
