#include "plugin/samp/core/vehicle.h"

bool
plugin::samp::vehicle::is_engine_active() const {
    return *reinterpret_cast<int*>(handle + 0x50) == 1;
}

bool
plugin::samp::vehicle::is_locked() const {
    return *reinterpret_cast<int*>(handle + 0x60) == 1;
}
