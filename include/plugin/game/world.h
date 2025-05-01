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

class world {
public:
    struct processed_line_of_sight {
        types::vector_3d pos;
        types::vector_3d normal;
        entity entity;
    }; // struct processed_line_of_sight

    enum class line_of_sight_condition : std::uint8_t {
        buildings = 1 << 0,
        vehicles = 1 << 1,
        peds = 1 << 2,
        objects = 1 << 3,
        dummies = 1 << 4,
        see_through = 1 << 5,
        camera_ignore = 1 << 6,
        shoot_through = 1 << 7
    }; // enum class line_of_sight_condition : std::uint8_t
private:
    static inline types::address<signatures::process_line_of_sight> process_line_of_sight_address = 0x56BA00;
public:
    static std::optional<processed_line_of_sight> process_line_of_sight(const types::vector_3d& origin, const types::vector_3d& target,
            const types::options<line_of_sight_condition>& conditions = line_of_sight_condition::buildings) noexcept;
}; // class world

} // namespace game
} // namespace plugin

#endif // GADMIN_PLUGIN_GAME_WORLD_H
