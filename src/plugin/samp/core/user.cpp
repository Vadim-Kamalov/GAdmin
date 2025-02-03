#include "plugin/samp/core/user.h"

std::uint16_t
plugin::samp::user::get_id() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x4, 0x2F1C, 0x4, 0x0 };
    return *reinterpret_cast<std::uint16_t*>(player_pool::get() + offsets[std::to_underlying(get_version())]);
}

std::string
plugin::samp::user::get_name() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0xA, 0x2F22, 0xA, 0x6 };
    return std::string(reinterpret_cast<char*>(player_pool::get() + offsets[std::to_underlying(get_version())]));
}

int
plugin::samp::user::get_ping() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x6A200, 0x6E150, 0x6E8C0, 0x6E2F0 };
    return reinterpret_cast<signatures::get_local_player_ping_t>(base(offsets))(player_pool::get());
}
