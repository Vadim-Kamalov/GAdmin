#ifndef GADMIN_PLUGIN_SAMP_CORE_NET_GAME_H
#define GADMIN_PLUGIN_SAMP_CORE_NET_GAME_H

#include "plugin/utils.h"
#include <cstdint>

namespace plugin {
namespace signatures {

using get_player_pool_t = std::uintptr_t(__thiscall*)(std::uintptr_t);
using update_players_t = void(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp::net_game {

std::uintptr_t instance() noexcept;
utils::zstring_t get_host_address() noexcept;

void update_players() noexcept;

} // namespace samp::net_game
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_NET_GAME_H
