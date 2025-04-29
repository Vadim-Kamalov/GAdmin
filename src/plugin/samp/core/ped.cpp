#include "plugin/samp/core/ped.h"
#include <cmath>

plugin::types::versioned_address_container<plugin::signatures::get_current_weapon_t>
plugin::samp::ped::get_current_weapon_container = { 0xA6510, 0xAB3C0, 0xABC50, 0xAB870 };
    
plugin::types::versioned_address_container<plugin::signatures::get_bone_position>
plugin::samp::ped::get_bone_position_container = { 0xA8D70, 0xADBF0, 0xAE480, 0xAE080 };

plugin::game::ped
plugin::samp::ped::get_game_ped() const {
    return game_ped.read(*handle);
}

plugin::game::weapon
plugin::samp::ped::get_current_weapon() const {
    return static_cast<game::weapon>(get_current_weapon_container->invoke(*handle));
}
