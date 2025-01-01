#ifndef GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H
#define GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H

#include "plugin/samp/core/entity.h"

namespace plugin {
namespace signatures {

using is_exist_t = int(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

class vehicle : public entity {
public:
    bool is_exist() const;
    using entity::entity;
}; // class vehicle : public entity

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_VEHICLE_H
