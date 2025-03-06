#include "plugin/samp/core/ped.h"
#include <cmath>

plugin::types::versioned_address_container<plugin::signatures::get_current_weapon_t>
plugin::samp::ped::get_current_weapon_container = { 0xA6510, 0xAB3C0, 0xABC50, 0xAB870 };

plugin::samp::ped::meters_per_second
plugin::samp::ped::get_speed() const {
    types::vector_3d speed = game_ped_speed.read(game_ped.read(*handle));
    return std::ceil(speed.magnitude() * 50);
}

plugin::game::weapon
plugin::samp::ped::get_current_weapon() const {
    return static_cast<game::weapon>(get_current_weapon_container->invoke(*handle));
}
