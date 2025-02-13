#include "plugin/samp/core/player_death_notification.h"
#include "plugin/game/weapon.h"

std::string
plugin::samp::player_death_notification::get_reason() const {
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

plugin::samp::player_death_notification::player_death_notification(samp::bit_stream* stream) {
    killer_id = stream->read<std::uint16_t>();
    killed_id = stream->read<std::uint16_t>();
    reason = stream->read<std::uint8_t>();
}
