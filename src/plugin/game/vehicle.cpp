#include "plugin/game/vehicle.h"

auto plugin::game::vehicle::has_driver() const -> bool {
    return driver_offset.read(*handle) != 0;
}
