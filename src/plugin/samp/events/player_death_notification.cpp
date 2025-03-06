#include "plugin/samp/events/player_death_notification.h"
#include "plugin/game/weapon.h"

std::string
plugin::samp::event<plugin::samp::event_id::player_death_notification>::get_reason() const {
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
