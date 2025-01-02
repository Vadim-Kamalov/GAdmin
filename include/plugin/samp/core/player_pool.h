#ifndef GADMIN_PLUGIN_SAMP_CORE_PLAYER_POOL_H
#define GADMIN_PLUGIN_SAMP_CORE_PLAYER_POOL_H

#include "plugin/samp/core/remote_player.h"
#include <cstdint>
#include <string_view>
#include <expected>

namespace plugin {
namespace signatures {

using get_player_pool_t = std::uintptr_t(__thiscall*)(std::uintptr_t);
using get_nickname_t = const char*(__thiscall*)(std::uintptr_t, std::uint16_t);
using is_connected_t = bool(__thiscall*)(std::uintptr_t, std::uint16_t);
using get_remote_player_t = std::uintptr_t(__thiscall*)(std::uintptr_t, std::uint16_t);
using get_ping_t = std::int32_t(__thiscall*)(std::uintptr_t, std::uint16_t);

} // namespace signatures

namespace samp {

class player_pool {
public:
    enum class error { player_not_connected, player_not_found };
public:
    static std::uintptr_t get() noexcept;

    static std::expected<std::string, error> get_nickname(std::uint16_t id) noexcept;
    static std::expected<std::uint16_t, error> get_id(const std::string_view& nickname) noexcept;

    static std::expected<remote_player, error> get_remote_player(std::uint16_t id, bool check_connection = true) noexcept;
    static std::expected<remote_player, error> get_remote_player(const std::string_view& nickname) noexcept;

    static std::expected<std::int32_t, error> get_ping(std::uint16_t id) noexcept;
    static bool is_connected(std::uint16_t id) noexcept;
}; // class player_pool

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_PLAYER_POOL_H
