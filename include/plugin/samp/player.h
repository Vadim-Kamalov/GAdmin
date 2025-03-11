#ifndef GADMIN_PLUGIN_SAMP_PLAYER_H
#define GADMIN_PLUGIN_SAMP_PLAYER_H

#include "plugin/samp/core/ped.h"
#include "plugin/types/color.h"
#include <cstdint>
#include <string>
#include <vector>

namespace plugin::samp {

class player {
public:
    using id_t = std::uint16_t;
    using nickname_t = std::string;
    using ping_t = int;

    static constexpr id_t id_none = 0xFFFF;
    static constexpr nickname_t nickname_none = "";

    using stream_entry_t = std::pair<player, ped>;
private:
    bool local_player = false, valid = false;
    void write_local_player(id_t new_id);
public:
    id_t id = id_none;
    nickname_t nickname = nickname_none;
    
    types::color get_color() const;
    ping_t get_ping() const;
    
    bool is_available() const;
    explicit operator bool() const;

    static std::vector<stream_entry_t> get_stream_players();
    
    explicit player(id_t new_id);
}; // class player

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_PLAYER_H
