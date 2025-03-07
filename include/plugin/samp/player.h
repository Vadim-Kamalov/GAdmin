#ifndef GADMIN_PLUGIN_SAMP_PLAYER_H
#define GADMIN_PLUGIN_SAMP_PLAYER_H

#include "plugin/types/color.h"
#include <cstdint>
#include <string>

namespace plugin::samp {

class player {
public:
    using id_t = std::uint16_t;
    using nickname_t = std::string;
    using ping_t = int;

    static constexpr id_t id_none = 0xFFFF;
    static constexpr nickname_t nickname_none = "";
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

    explicit player(id_t new_id);
}; // class player

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_PLAYER_H
