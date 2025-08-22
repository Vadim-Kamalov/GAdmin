#include "plugin/samp/events/player_death_notification.h"
#include "plugin/game/weapon.h"
#include "plugin/samp/core/player_pool.h"

auto plugin::samp::event<plugin::samp::event_id::player_death_notification>::to_string() const -> std::string {
    auto killed_nickname = samp::player_pool::get_nickname(killed_id);

    if (!killed_nickname)
        return "";

    if (killer_id != id_none) {
        auto killer_nickname = samp::player_pool::get_nickname(killer_id);

        if (!killer_nickname)
            return "";
        
        return std::format("{}[{}] убил {}[{}] с помощью {}.", *killer_nickname,
                           killer_id, *killed_nickname, killed_id, get_reason());
    }

    return std::format("{}[{}] погиб от {}.", *killed_nickname, killed_id, get_reason());
}

auto plugin::samp::event<plugin::samp::event_id::player_death_notification>::get_reason() const
    -> std::string
{
    switch (reason) {
        case special_reason_car: return "Vehicle";
        case special_reason_helicopter: return "Helicopter";
        case special_reason_explosion: return "Explosion";
        case special_reason_drowned: return "Drowned";
        case special_reason_suicide: return "Suicide";
        case 0 ... 18: case 22 ... 46: return game::weapon_names[reason];
        default: return "Unknown";
    }
}

plugin::samp::event<plugin::samp::event_id::player_death_notification>::event(bit_stream* stream) {
    stream->read_into(killer_id, killed_id, reason);
}
