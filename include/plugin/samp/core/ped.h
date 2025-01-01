#ifndef GADMIN_PLUGIN_SAMP_CORE_PED_H
#define GADMIN_PLUGIN_SAMP_CORE_PED_H

#include "plugin/samp/core/entity.h"
#include "plugin/samp/core/vehicle.h"
#include <cstdint>

namespace plugin {
namespace signatures {

using get_current_weapon_t = char(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

class ped : public entity {
private:
    std::uintptr_t remote_player;
    std::uintptr_t get_game_ped() const;
public:
    using meters_per_second = float;
public:
    meters_per_second get_speed() const;
    float get_armor() const;
    char get_current_weapon() const;
    vehicle get_vehicle() const;

    explicit ped(std::uintptr_t handle, std::uintptr_t remote_player)
        : entity(handle), remote_player(remote_player) {} 
}; // class ped

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_PED_H
