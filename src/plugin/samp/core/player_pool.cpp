#include "plugin/samp/core/player_pool.h"
#include "plugin/samp/core/net_game.h"
#include "plugin/samp/core/remote_player.h"
#include "plugin/samp/core/user.h"
#include "plugin/samp/samp.h"

plugin::types::versioned_address_container<plugin::signatures::get_player_pool_t>
plugin::samp::player_pool::get_player_pool_container = { 0x1160, 0x1160, 0x1170, 0x1170 };

plugin::types::versioned_address_container<plugin::signatures::get_nickname_t>
plugin::samp::player_pool::get_nickname_container = { 0x13CE0, 0x16F00, 0x175C0, 0x170D0 };

plugin::types::versioned_address_container<plugin::signatures::get_ping_t>
plugin::samp::player_pool::get_ping_container = { 0x6A1C0, 0x6E110, 0x6E880, 0x6E2B0 };

std::uintptr_t
plugin::samp::player_pool::instance() noexcept {
    return get_player_pool_container->invoke(net_game::instance_container->read());
}

std::expected<std::string, plugin::samp::player_pool::error>
plugin::samp::player_pool::get_nickname(std::uint16_t id) noexcept {
    if (user::get_id() == id)
        return user::get_name();

    if (!is_connected(id))
        return std::unexpected(error::player_not_connected);

    net_game::update_players();

    return get_nickname_container->invoke(instance(), id);
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

    return remote_player((get_remote_player_offset + get_base())(instance(), id));
}

std::expected<plugin::samp::remote_player, plugin::samp::player_pool::error>
plugin::samp::player_pool::get_remote_player(const std::string_view& nickname) noexcept {
    if (auto id = get_id(nickname))
        return get_remote_player(*id, false);
    else
        return std::unexpected(id.error());
}

std::expected<std::int32_t, plugin::samp::player_pool::error>
plugin::samp::player_pool::get_ping(std::uint16_t id) noexcept {
    if (!is_connected(id))
        return std::unexpected(error::player_not_connected);

    return get_ping_container->invoke(instance(), id);
}

bool
plugin::samp::player_pool::is_connected(std::uint16_t id) noexcept {
    return id == user::get_id() || (is_connected_offset + get_base())(instance(), id);
}
