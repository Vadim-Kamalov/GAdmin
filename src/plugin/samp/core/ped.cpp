#include "plugin/samp/core/ped.h"

plugin::types::versioned_address_container<plugin::signatures::get_current_weapon_t>
plugin::samp::ped::get_current_weapon_container = { 0xA6510, 0xAB3C0, 0xABC50, 0xAB870 };

auto plugin::samp::ped::get_game_ped() const -> game::ped {
    return game_ped.read(*handle);
}

auto plugin::samp::ped::get_current_weapon() const -> game::weapon {
    return static_cast<game::weapon>(get_current_weapon_container->invoke(*handle));
}
