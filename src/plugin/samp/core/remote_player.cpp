#include "plugin/samp/core/remote_player.h"
#include "plugin/samp/samp.h"

plugin::samp::ped
plugin::samp::remote_player::get_ped() const {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x0, 0x0, 0x1DD, 0x4 };
    return ped(*reinterpret_cast<std::uintptr_t*>(handle + offsets[std::to_underlying(get_version())]), handle);
}
