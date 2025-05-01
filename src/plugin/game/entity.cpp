#include "plugin/game/entity.h"
#include "plugin/game/vehicle.h"

void
plugin::game::entity::set_coordinates(const types::vector_3d& pos) const {
    position_offset_in_matrix.write(pos, matrix_offset.read(*handle));
}

void
plugin::game::entity::teleport(const types::vector_3d& pos) const {
    set_coordinates(pos);
}

std::uint16_t
plugin::game::entity::get_model_index() const {
    return model_index_offset.read(*handle);
}

plugin::types::vector_3d
plugin::game::entity::get_position() const {
    return position_offset_in_matrix.read(matrix_offset.read(*handle));
}

plugin::game::vehicle
plugin::game::entity::get_vehicle() const {
    if (!is_vehicle_pointer_valid_address(*handle))
        return vehicle(0);

    return vehicle(*handle);
}
