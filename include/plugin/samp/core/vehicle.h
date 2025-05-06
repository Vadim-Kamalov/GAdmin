#ifndef GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H
#define GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H

#include "plugin/game/vehicle.h"
#include "plugin/samp/core/entity.h"
#include "plugin/types/address.h"

namespace plugin::samp {

class vehicle : public entity {
private:
    static inline types::offset<int> engine_active_offset = 0x50;
    static inline types::offset<int> locked_offset = 0x60;
    static inline types::offset<game::vehicle> game_vehicle_offset = 0x4C;
public:
    game::vehicle get_game_vehicle() const;

    bool is_engine_active() const;
    bool is_locked() const;

    using entity::entity;
}; // class vehicle : public entity

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H
