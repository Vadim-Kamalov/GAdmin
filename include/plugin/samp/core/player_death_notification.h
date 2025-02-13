#ifndef GADMIN_PLUGIN_SAMP_CORE_PLAYER_DEATH_NOTIFICATION_H
#define GADMIN_PLUGIN_SAMP_CORE_PLAYER_DEATH_NOTIFICATION_H

#include "plugin/samp/network/bit_stream.h"

namespace plugin::samp {

class player_death_notification {
private:
    enum special_reason {
        special_reason_car = 49,
        special_reason_helicopter,
        special_reason_explosion,
        special_reason_drowned = 53,
        special_reason_suicide
    }; // enum special_reason
public:
    static constexpr std::uint8_t event_id = 55;

    std::uint16_t killer_id = 0xFFFF;
    std::uint16_t killed_id = 0xFFFF;
    std::uint8_t reason = 0xFF;

    std::string get_reason() const;

    explicit player_death_notification(samp::bit_stream* stream);
}; // class player_death_notification

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_PLAYER_DEATH_NOTIFICATION_H
