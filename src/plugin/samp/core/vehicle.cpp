#include "plugin/samp/core/vehicle.h"

plugin::game::vehicle
plugin::samp::vehicle::get_game_vehicle() const {
    return game_vehicle_offset.read(*handle);
}

bool
plugin::samp::vehicle::is_engine_active() const {
    return engine_active_offset.read(*handle) == 1;
}

bool
plugin::samp::vehicle::is_locked() const {
    return locked_offset.read(*handle) == 1;
}
