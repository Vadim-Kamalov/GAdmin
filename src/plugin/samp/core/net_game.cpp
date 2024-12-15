#include "plugin/samp/core/net_game.h"
#include "plugin/samp/samp.h"

std::uintptr_t
plugin::samp::net_game::instance() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x21A0F8, 0x26E8DC, 0x26EB94, 0x2ACA24 };
    return *reinterpret_cast<std::uintptr_t*>(base(offsets));
}

const char*
plugin::samp::net_game::get_host_address() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x20, 0x34, 0x34, 0x34 };
    return reinterpret_cast<char*>(instance() + offsets[std::to_underlying(get_version())]);
}

std::uintptr_t
plugin::samp::net_game::get_player_pool() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x1160, 0x1160, 0x1170, 0x1170 };
    return reinterpret_cast<signatures::get_player_pool_t>(base(offsets))(instance());
}
