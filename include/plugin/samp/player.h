#ifndef GADMIN_PLUGIN_SAMP_PLAYER_H
#define GADMIN_PLUGIN_SAMP_PLAYER_H

#include "plugin/types/address.h"
#include <cstdint>
#include <string>
#include <optional>

namespace plugin::samp {

class player {
public:
    using id_t = std::uint16_t;
    using nickname_t = std::string;

    static constexpr id_t id_none = 0xFFFF;
    static constexpr nickname_t nickname_none = "";
private:
    bool local_player = false, valid = true;
    std::optional<types::address<std::uintptr_t>> handle;
public:
    id_t id = id_none;
    nickname_t nickname = nickname_none;

    bool is_available() const;
    explicit operator bool() const;

    explicit player(id_t id);
}; // class player

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_PLAYER_H
