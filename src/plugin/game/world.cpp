#include "plugin/game/world.h"
#include "plugin/game/entity.h"
#include <memory>

std::optional<plugin::game::world::processed_line_of_sight>
plugin::game::world::process_line_of_sight(const types::vector_3d& origin, const types::vector_3d& target,
                                           const types::options<line_of_sight_condition>& conditions) noexcept
{
    types::vector_3d* vector_origin = const_cast<types::vector_3d*>(std::addressof(origin));
    types::vector_3d* vector_target = const_cast<types::vector_3d*>(std::addressof(target));
    std::uintptr_t entity_ptr = 0;
    
    struct {
        types::vector_3d pos;
        float unused;
        types::vector_3d normal;
    } point;

    if (!process_line_of_sight_address(vector_origin, vector_target, reinterpret_cast<std::uintptr_t>(&point), &entity_ptr,
                                       conditions.has_value(line_of_sight_condition::buildings),
                                       conditions.has_value(line_of_sight_condition::vehicles),
                                       conditions.has_value(line_of_sight_condition::peds),
                                       conditions.has_value(line_of_sight_condition::objects),
                                       conditions.has_value(line_of_sight_condition::dummies),
                                       conditions.has_value(line_of_sight_condition::see_through),
                                       conditions.has_value(line_of_sight_condition::camera_ignore),
                                       conditions.has_value(line_of_sight_condition::shoot_through)))
    {
        return {};
    }

    return processed_line_of_sight {
        .pos = point.pos,
        .normal = point.normal,
        .entity = entity(entity_ptr)
    };
}
