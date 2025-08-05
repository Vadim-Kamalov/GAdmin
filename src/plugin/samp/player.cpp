#include "plugin/samp/player.h"
#include "plugin/samp/core/player_pool.h"
#include "plugin/samp/core/user.h"

auto plugin::samp::player::write_local_player(id_t new_id) -> void {
    local_player = valid = true;
    nickname = user::get_name();
    id = new_id;
}

auto plugin::samp::player::get_color() const -> types::color {
    if (local_player)
        return user::get_color();

    if (auto remote_player = player_pool::get_remote_player(id))
        return remote_player->get_color();

    return 0;
}

auto plugin::samp::player::get_ping() const -> ping_t {
    if (local_player)
        return user::get_ping();

    if (auto ping = player_pool::get_ping(id))
        return *ping;

    return 0;
}

auto plugin::samp::player::is_available() const -> bool {
    return valid;
}

auto plugin::samp::player::get_stream_players() -> std::deque<stream_entry_t> {
    std::deque<stream_entry_t> players;

    for (id_t stream_id = 0; stream_id <= SERVER_MAX_PLAYERS; stream_id++) {
        if (stream_id == user::get_id())
            continue;

        auto remote_player = player_pool::get_remote_player(stream_id);

        if (!remote_player.has_value())
            continue;

        auto ped = remote_player->get_ped();

        if (!ped.is_available())
            continue;

        players.emplace_back(player(stream_id), ped);
    }

    return players;
}

plugin::samp::player::operator bool() const {
    return is_available();
}

plugin::samp::player::player(id_t new_id) {
    if (user::get_id() == new_id) {
        write_local_player(new_id);
        return;
    }

    if (auto new_nickname = player_pool::get_nickname(new_id))
        nickname = *new_nickname;
    else
        return;

    id = new_id;
    valid = true;
}

plugin::samp::player::player(const nickname_t& new_nickname) {
    if (user::get_name() == new_nickname) {
        write_local_player(user::get_id());
        return;
    }

    if (auto new_id = player_pool::get_id(new_nickname))
        id = *new_id;
    else
        return;

    nickname = new_nickname;
    valid = true;
}
