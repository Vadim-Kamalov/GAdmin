#ifndef GADMIN_PLUGIN_SAMP_CORE_PED_H
#define GADMIN_PLUGIN_SAMP_CORE_PED_H

#include "plugin/samp/core/entity.h"
#include <cstdint>

namespace plugin {
namespace signatures {

using get_current_weapon_t = char(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

class ped : public entity {
private:
    std::uintptr_t get_game_ped() const;
public:
    using meters_per_second = float;
public:
    meters_per_second get_speed() const;
    char get_current_weapon() const;
    
    using entity::entity;
}; // class ped

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_PED_H
