#include "plugin/samp/core/vehicle.h"
#include "plugin/samp/samp.h"

bool
plugin::samp::vehicle::is_exist() const {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0xB1BE0, 0xB78A0, 0xB8140, 0xB7C70 };
    return reinterpret_cast<signatures::is_exist_t>(base(offsets))(handle);
}
