#ifndef GADMIN_PLUGIN_SAMP_CORE_NET_GAME_H
#define GADMIN_PLUGIN_SAMP_CORE_NET_GAME_H

#include "plugin/samp/samp.h"
#include <cstring>

namespace plugin::samp::net_game {

static inline std::uintptr_t
instance() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x21A0F8, 0x26E8DC, 0x26EB94, 0x2ACA24 };
    return *reinterpret_cast<std::uintptr_t*>(base(offsets[std::to_underlying(get_version())]));
}

static inline const char*
get_host_address() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x20, 0x34, 0x34, 0x34 };
    return reinterpret_cast<char*>(instance() + offsets[std::to_underlying(get_version())]);
}

} // namespace plugin::samp::net_game

#endif // GADMIN_PLUGIN_SAMP_CORE_NET_GAME_H
