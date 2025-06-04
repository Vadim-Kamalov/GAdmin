#ifndef GADMIN_PLUGIN_SAMP_EVENTS_PLAYER_DEATH_NOTIFICATION_H
#define GADMIN_PLUGIN_SAMP_EVENTS_PLAYER_DEATH_NOTIFICATION_H

#include "plugin/samp/events/event.h"

namespace plugin::samp {

template<>
class event<event_id::player_death_notification> final {
private:
    enum special_reason {
        special_reason_car = 49,
        special_reason_helicopter,
        special_reason_explosion,
        special_reason_drowned = 53,
        special_reason_suicide
    }; // enum special_reason 
public:
    static constexpr std::uint16_t id_none = 0xFFFF;
    
    std::uint16_t killer_id = id_none;
    std::uint16_t killed_id = id_none;
    std::uint8_t reason = 0xFF;

    auto get_reason() const -> std::string;

    explicit event(bit_stream* stream);
}; // class event<event_id::player_death_notification> final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_PLAYER_DEATH_NOTIFICATION_H
