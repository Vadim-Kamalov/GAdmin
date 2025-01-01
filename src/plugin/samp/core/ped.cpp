#include "plugin/samp/core/ped.h"
#include "plugin/samp/samp.h"
#include <cmath>
#include <cstdint>

std::uintptr_t
plugin::samp::ped::get_game_ped() const {
    return *reinterpret_cast<std::uintptr_t*>(handle + 0x2A4); 
}

plugin::samp::ped::meters_per_second
plugin::samp::ped::get_speed() const {
    float x = *reinterpret_cast<float*>(get_game_ped() + 0x44);
    float y = *reinterpret_cast<float*>(get_game_ped() + 0x48);
    float z = *reinterpret_cast<float*>(get_game_ped() + 0x4C);
    return std::ceil(std::hypot(x, y, z) * 50);
}

float
plugin::samp::ped::get_armor() const {
    return *reinterpret_cast<float*>(remote_player + ((get_version() == samp::version::v037R1) ? 0x1B8 : 0x1AC));
}

char
plugin::samp::ped::get_current_weapon() const {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0xA6510, 0xAB3C0, 0xABC50, 0xAB870 };
    return reinterpret_cast<signatures::get_current_weapon_t>(base(offsets))(handle);
}

plugin::samp::vehicle
plugin::samp::ped::get_vehicle() const {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x4, 0x4, 0x1E1, 0x8 };
    return vehicle(*reinterpret_cast<std::uintptr_t*>(remote_player + offsets[std::to_underlying(get_version())]));
}
