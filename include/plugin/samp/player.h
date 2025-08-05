#ifndef GADMIN_PLUGIN_SAMP_PLAYER_H
#define GADMIN_PLUGIN_SAMP_PLAYER_H

#include "plugin/samp/core/ped.h"
#include "plugin/types/color.h"
#include <cstdint>
#include <string>
#include <deque>

namespace plugin::samp {

class player final {
public:
    using id_t = std::uint16_t;
    using nickname_t = std::string;
    using stream_entry_t = std::pair<player, ped>;
    using ping_t = int;

    static constexpr id_t id_none = 0xFFFF;
    static constexpr nickname_t nickname_none = "";
private:
    bool local_player = false, valid = false;
    auto write_local_player(id_t new_id) -> void;
public:
    id_t id = id_none;
    nickname_t nickname = nickname_none;
    
    auto get_color() const -> types::color;
    auto get_ping() const -> ping_t;
    
    auto is_available() const -> bool;
    explicit operator bool() const;

    static auto get_stream_players() -> std::deque<stream_entry_t>;
    
    explicit player(id_t new_id);
    explicit player(const nickname_t& new_nickname);
}; // class player final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_PLAYER_H
