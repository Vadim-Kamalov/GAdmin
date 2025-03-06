#include "plugin/samp/core/remote_player.h"

plugin::types::versioned_address_container<plugin::samp::ped, plugin::types::version_container_option::offsets>
plugin::samp::remote_player::ped_container = { 0x0, 0x0, 0x1DD, 0x4 };

plugin::types::versioned_address_container<plugin::samp::vehicle, plugin::types::version_container_option::offsets>
plugin::samp::remote_player::vehicle_container = { 0x4, 0x4, 0x1E1, 0x8 };

plugin::types::versioned_address_container<float, plugin::types::version_container_option::offsets>
plugin::samp::remote_player::armor_container = { 0x1B8, 0x1AC, 0x1AC, 0x1AC };

plugin::types::versioned_address_container<plugin::signatures::get_color_as_argb>
plugin::samp::remote_player::get_color_container = { 0x12A00, 0x15C10, 0x16180, 0x15E30 };

bool
plugin::samp::remote_player::is_available() const {
    return handle.is_available();
}

plugin::samp::ped
plugin::samp::remote_player::get_ped() const {
    return ped_container->read(*handle);
}

plugin::samp::vehicle
plugin::samp::remote_player::get_vehicle() const {
    return vehicle_container->read(*handle);
}

float
plugin::samp::remote_player::get_armor() const {
    return armor_container->read(*handle);
}

plugin::types::color
plugin::samp::remote_player::get_color() const {
    return types::color::argb(get_color_container->invoke(*handle));
}
