#ifndef GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H
#define GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H

#include "plugin/samp/core/entity.h"
#include "plugin/types/address.h"

namespace plugin::samp {

class vehicle : public entity {
private:
    static inline types::offset<int> engine_active_offset = 0x50;
    static inline types::offset<int> locked_offset = 0x60;
public:
    bool is_engine_active() const;
    bool is_locked() const;

    using entity::entity;
}; // class vehicle : public entity

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H
