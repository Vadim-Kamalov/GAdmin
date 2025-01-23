#include "plugin/samp/core/remote_player.h"
#include "plugin/samp/samp.h"

bool
plugin::samp::remote_player::is_available() const {
    return handle != 0;
}

plugin::samp::ped
plugin::samp::remote_player::get_ped() const {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x0, 0x0, 0x1DD, 0x4 };
    return ped(*reinterpret_cast<std::uintptr_t*>(handle + offsets[std::to_underlying(get_version())]));
}

plugin::samp::vehicle
plugin::samp::remote_player::get_vehicle() const {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x4, 0x4, 0x1E1, 0x8 };
    return vehicle(*reinterpret_cast<std::uintptr_t*>(handle + offsets[std::to_underlying(get_version())]));
}

float
plugin::samp::remote_player::get_armor() const {
    return *reinterpret_cast<float*>(handle + ((get_version() == samp::version::v037R1) ? 0x1B8 : 0x1AC));
}
