#ifndef GADMIN_PLUGIN_SAMP_CORE_NET_GAME_H
#define GADMIN_PLUGIN_SAMP_CORE_NET_GAME_H

#include <cstdint>

namespace plugin {
namespace signatures {

using GetPlayerPool = std::uintptr_t(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp::net_game {

std::uintptr_t instance() noexcept;
const char* get_host_address() noexcept;
std::uintptr_t get_player_pool() noexcept;

} // namespace samp::net_game
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_NET_GAME_H
