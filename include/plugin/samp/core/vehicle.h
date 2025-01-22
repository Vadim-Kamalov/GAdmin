#ifndef GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H
#define GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H

#include "plugin/samp/core/entity.h"

namespace plugin::samp {

class vehicle : public entity {
public:
    bool is_engine_active() const;
    bool is_locked() const;

    using entity::entity;
}; // class vehicle : public entity

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H
