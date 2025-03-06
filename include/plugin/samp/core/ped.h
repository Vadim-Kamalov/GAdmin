#ifndef GADMIN_PLUGIN_SAMP_CORE_PED_H
#define GADMIN_PLUGIN_SAMP_CORE_PED_H

#include "plugin/game/weapon.h"
#include "plugin/samp/core/entity.h"
#include "plugin/types/simple.h"

namespace plugin {
namespace signatures {

using get_current_weapon_t = char(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

class ped : public entity {
private:
    static inline types::offset<std::uintptr_t> game_ped = 0x2A4;
    static inline types::offset<types::vector_3d> game_ped_speed = 0x44;
    static types::versioned_address_container<signatures::get_current_weapon_t> get_current_weapon_container;
public:
    using meters_per_second = float;
public:
    meters_per_second get_speed() const;
    game::weapon get_current_weapon() const;
    
    using entity::entity;
}; // class ped

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_PED_H
