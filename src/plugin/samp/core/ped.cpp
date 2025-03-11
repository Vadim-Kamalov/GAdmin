#include "plugin/samp/core/ped.h"
#include <cmath>

plugin::types::versioned_address_container<plugin::signatures::get_current_weapon_t>
plugin::samp::ped::get_current_weapon_container = { 0xA6510, 0xAB3C0, 0xABC50, 0xAB870 };

plugin::types::vector_3d
plugin::samp::ped::get_position() const {
    std::uintptr_t ped = game_ped.read(*handle);
    std::uintptr_t position_rotation = game_ped_position_rotation.read(ped);
    return game_ped_position.read(position_rotation);
}

plugin::samp::ped::meters_per_second
plugin::samp::ped::get_speed() const {
    types::vector_3d speed = game_ped_speed.read(game_ped.read(*handle));
    return std::ceil(speed.magnitude() * 50);
}

plugin::game::weapon
plugin::samp::ped::get_current_weapon() const {
    return static_cast<game::weapon>(get_current_weapon_container->invoke(*handle));
}
