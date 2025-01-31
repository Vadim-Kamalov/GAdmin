#include "plugin/samp/core/net_game.h"
#include "plugin/samp/samp.h"

std::uintptr_t
plugin::samp::net_game::instance() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x21A0F8, 0x26E8DC, 0x26EB94, 0x2ACA24 };
    return *reinterpret_cast<std::uintptr_t*>(base(offsets));
}

plugin::utils::zstring_t
plugin::samp::net_game::get_host_address() noexcept {
    return reinterpret_cast<char*>(instance() + ((get_version() == samp::version::v037R1) ? 0x20 : 0x30));
}

void
plugin::samp::net_game::update_players() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x8A10, 0x8BA0, 0x8F10, 0x8C00 };
    return reinterpret_cast<signatures::update_players_t>(base(offsets))(instance());
}
