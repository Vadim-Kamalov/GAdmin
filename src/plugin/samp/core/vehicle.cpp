#include "plugin/samp/core/vehicle.h"

auto plugin::samp::vehicle::get_game_vehicle() const -> game::vehicle {
    return game_vehicle_offset.read(*handle);
}

auto plugin::samp::vehicle::is_engine_active() const -> bool {
    return engine_active_offset.read(*handle) == 1;
}

auto plugin::samp::vehicle::is_locked() const -> bool {
    return locked_offset.read(*handle) == 1;
}
