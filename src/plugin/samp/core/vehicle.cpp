#include "plugin/samp/core/vehicle.h"

bool
plugin::samp::vehicle::is_engine_active() const {
    return engine_active_offset.read(*handle) == 1;
}

bool
plugin::samp::vehicle::is_locked() const {
    return locked_offset.read(*handle) == 1;
}
