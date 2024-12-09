#include "plugin/samp/core/user.h"
#include "plugin/samp/core/net_game.h"
#include "plugin/samp/samp.h"

std::uint16_t
plugin::samp::user::get_id() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x4, 0x3ECC, 0x4, 0x0 };
    return *reinterpret_cast<std::uint16_t*>(net_game::get_player_pool() + offsets[std::to_underlying(get_version())]);
}

std::string
plugin::samp::user::get_name() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0xA, 0x3ED2, 0x10, 0x6 };
    return std::string(reinterpret_cast<char*>(net_game::get_player_pool() + offsets[std::to_underlying(get_version())]));
}

int
plugin::samp::user::get_ping() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x6A200, 0x6E150, 0x6E8C0, 0x6E2F0 };
    return reinterpret_cast<signatures::GetLocalPlayerPing>(base(offsets[std::to_underlying(get_version())]))
        (net_game::get_player_pool());
}
