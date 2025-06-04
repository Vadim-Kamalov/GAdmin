#ifndef GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H
#define GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H

#include "plugin/game/vehicle.h"
#include "plugin/samp/core/entity.h"
#include "plugin/types/address.h"

namespace plugin::samp {

class vehicle final : public entity {
private:
    static inline types::offset<int> engine_active_offset = 0x50;
    static inline types::offset<int> locked_offset = 0x60;
    static inline types::offset<game::vehicle> game_vehicle_offset = 0x4C;
public:
    auto get_game_vehicle() const -> game::vehicle;
    auto is_engine_active() const -> bool;
    auto is_locked() const -> bool;

    using entity::entity;
}; // class vehicle final : public entity

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H
