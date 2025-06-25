#include "plugin/game/vehicle.h"

auto plugin::game::vehicle::has_driver() const -> bool {
    return driver_offset.read(*handle) != 0;
}

auto plugin::game::vehicle::get_health() const -> float {
    return health_offset.read(*handle);
}
