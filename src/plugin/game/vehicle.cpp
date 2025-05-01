#include "plugin/game/vehicle.h"

bool
plugin::game::vehicle::has_driver() const {
    return driver_offset.read(*handle) != 0;
}
