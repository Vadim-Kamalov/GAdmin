#include "plugin/game/ped.h"
#include <cmath>

bool
plugin::game::ped::is_on_screen() const {
    return is_on_screen_address(*handle);
}

bool
plugin::game::ped::is_in_the_air() const {
    return flags_offset.read(*handle).in_the_air;
}

plugin::types::meter_per_second_t
plugin::game::ped::get_speed() const {
    types::vector_3d speed = speed_offset.read(*handle);
    return std::ceil(speed.magnitude() * 50);
}

plugin::types::vector_3d
plugin::game::ped::get_bone_bosition(const bone& bone_id) const {
    types::vector_3d result;
    get_bone_position_address(*handle, &result, std::to_underlying(bone_id), false);
    return result;
}

plugin::game::ped
plugin::game::ped::get_player() noexcept {
    return player_address.read();
}

plugin::game::vehicle
plugin::game::ped::get_vehicle() const {
    if (!flags_offset.read(*handle).in_vehicle)
        return vehicle(0);

    return vehicle_offset.read(*handle);
}

void
plugin::game::ped::teleport(const types::vector_3d& pos) const {
    auto flags = reinterpret_cast<flags_t*>(*handle + *flags_offset);
    
    flags->is_standing = true;
    flags->was_standing = true;

    set_coordinates(pos);
}

void
plugin::game::ped::set_heading(float angle) const {
    angle = clamp_angle(angle) * deg_to_rad_multiplier;
    
    current_rotation_offset.write(angle, *handle);
    aiming_rotation_offset.write(angle, *handle);

    set_heading_in_rad(angle);
}
