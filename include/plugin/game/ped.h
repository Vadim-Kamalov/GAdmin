#ifndef GADMIN_PLUGIN_GAME_PED_H
#define GADMIN_PLUGIN_GAME_PED_H

#include "plugin/game/placeable.h"
#include "plugin/game/vehicle.h"
#include "plugin/types/address.h"

namespace plugin {
namespace signatures {

using teleport = void(__thiscall*)(std::uintptr_t, types::vector_3d, bool);
using get_distance_from_centre_of_mass = void(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace game {

class ped : public placeable {
public:
    struct flags_t {
        std::uint8_t is_standing : 1;
        std::uint8_t was_standing : 1;
        std::uint8_t : 6;
        std::uint8_t in_vehicle : 1;
        std::uint8_t in_the_air : 1;
    }; // struct flags_t
private:
    static inline types::address<signatures::teleport> teleport_address = 0x5E4110;
    static inline types::address<ped> player_address = 0xB6F5F0;
    static inline types::offset<vehicle> vehicle_offset = 0x58C;
    static inline types::offset<float> current_rotation_offset = 0x558;
    static inline types::offset<float> aiming_rotation_offset = 0x55C;
    static inline types::offset<flags_t> flags_offset = 0x46C;
public:
    bool is_in_the_air() const;

    vehicle get_vehicle() const;
    static ped get_player() noexcept;
    
    void teleport(const types::vector_3d& pos) const override;
    void set_heading(float angle) const override;

    using placeable::placeable;
}; // class ped

} // namespace game
} // namespace plugin

#endif // GADMIN_PLUGIN_GAME_PED_H
