#ifndef GADMIN_PLUGIN_SAMP_CORE_PLAYER_POOL_H
#define GADMIN_PLUGIN_SAMP_CORE_PLAYER_POOL_H

#include "plugin/samp/core/remote_player.h"
#include "plugin/types/address.h"
#include "plugin/types/simple.h"
#include <cstdint>
#include <string>
#include <expected>

namespace plugin {
namespace signatures {

using get_player_pool_t = std::uintptr_t(__thiscall*)(std::uintptr_t);
using get_nickname_t = types::zstring_t(__thiscall*)(std::uintptr_t, std::uint16_t);
using get_remote_player_t = std::uintptr_t(__thiscall*)(std::uintptr_t, std::uint16_t);
using is_connected_t = bool(__thiscall*)(std::uintptr_t, std::uint16_t);
using get_ping_t = std::int32_t(__thiscall*)(std::uintptr_t, std::uint16_t);

} // namespace signatures

namespace samp {

class player_pool {
public:
    enum class error { player_not_connected, player_not_found };
private:
    static types::versioned_address_container<signatures::get_player_pool_t> get_player_pool_container;
    static types::versioned_address_container<signatures::get_nickname_t> get_nickname_container;
    static types::versioned_address_container<signatures::get_ping_t> get_ping_container;
    static inline types::offset<signatures::get_remote_player_t> get_remote_player_offset = 0x10F0;
    static inline types::offset<signatures::get_remote_player_t> is_connected_offset = 0x10B0;
public:
    static std::uintptr_t instance() noexcept;

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
