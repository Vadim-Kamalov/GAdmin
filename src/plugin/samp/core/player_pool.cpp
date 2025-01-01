#include "plugin/samp/core/player_pool.h"
#include "plugin/samp/core/net_game.h"
#include "plugin/samp/core/remote_player.h"
#include "plugin/samp/core/user.h"
#include "plugin/samp/samp.h"

std::uintptr_t
plugin::samp::player_pool::get() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x1160, 0x1160, 0x1170, 0x1170 };
    return reinterpret_cast<signatures::get_player_pool_t>(base(offsets))(net_game::instance());
}

std::expected<std::string, plugin::samp::player_pool::error>
plugin::samp::player_pool::get_nickname(std::uint16_t id) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x13CE0, 0x16F00, 0x175C0, 0x170D0 };
    
    if (user::get_id() == id)
        return user::get_name();

    if (!is_connected(id))
        return std::unexpected(error::player_not_connected);

    net_game::update_players();

    return std::string(reinterpret_cast<signatures::get_nickname_t>(base(offsets))(get(), id));
}

std::expected<std::uint16_t, plugin::samp::player_pool::error>
plugin::samp::player_pool::get_id(const std::string_view& nickname) noexcept {
    if (user::get_name() == nickname)
        return user::get_id();
    
    for (std::uint16_t id = 0; id <= SERVER_MAX_PLAYERS; id++)
        if (get_nickname(id) == nickname)
            return id;

    return std::unexpected(error::player_not_found);
}

std::expected<plugin::samp::remote_player, plugin::samp::player_pool::error>
plugin::samp::player_pool::get_remote_player(std::uint16_t id, bool check_connection) noexcept {
    if (check_connection && !is_connected(id))
        return std::unexpected(error::player_not_connected);

    return remote_player(reinterpret_cast<signatures::get_remote_player_t>(base(0x10F0))(get(), id));
}

std::expected<plugin::samp::remote_player, plugin::samp::player_pool::error>
plugin::samp::player_pool::get_remote_player(const std::string_view& nickname) noexcept {
    if (auto id = get_id(nickname))
        return get_remote_player(*id, false);
    else
        return std::unexpected(id.error());
}

std::expected<plugin::samp::ped, plugin::samp::player_pool::error>
plugin::samp::player_pool::get_ped(std::uint16_t id) noexcept {
    if (auto remote_player = get_remote_player(id)) {
        ped ped = remote_player->get_ped();

        if (!ped.is_available())
            return std::unexpected(error::ped_null_pointer);

        return ped;
    } else
        return std::unexpected(remote_player.error());
}

std::expected<plugin::samp::ped, plugin::samp::player_pool::error>
plugin::samp::player_pool::get_ped(const std::string_view& nickname) noexcept {
    if (auto id = get_id(nickname))
        return get_ped(*id);
    else
        return std::unexpected(id.error());
}

std::expected<std::int32_t, plugin::samp::player_pool::error>
plugin::samp::player_pool::get_ping(std::uint16_t id) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x6A1C0, 0x6E110, 0x6E880, 0x6E2B0 };

    if (!is_connected(id))
        return std::unexpected(error::player_not_connected);

    return reinterpret_cast<signatures::get_ping_t>(base(offsets))(get(), id);
}

bool
plugin::samp::player_pool::is_connected(std::uint16_t id) noexcept {
    return reinterpret_cast<signatures::is_connected_t>(base(0x10B0))(get(), id);
}
