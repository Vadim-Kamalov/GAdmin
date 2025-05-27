#ifndef GADMIN_PLUGIN_GAME_PED_H
#define GADMIN_PLUGIN_GAME_PED_H

#include "plugin/game/placeable.h"
#include "plugin/game/vehicle.h"
#include "plugin/game/weapon.h"
#include "plugin/types/address.h"
#include "plugin/types/simple.h"

namespace plugin {
namespace signatures {

using teleport = void(__thiscall*)(std::uintptr_t, types::vector_3d, bool);
using get_bone_position = void(__thiscall*)(std::uintptr_t, types::vector_3d*, int, bool);
using task_process_ped = bool(__thiscall*)(std::uintptr_t, std::uintptr_t);

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

    enum bone { head = 6 };
private:
    static inline types::address<signatures::teleport> teleport_address = 0x5E4110;
    static inline types::address<signatures::get_bone_position> get_bone_position_address = 0x5E4280;
    static inline types::address<ped> player_address = 0xB6F5F0;
    static inline types::offset<vehicle> vehicle_offset = 0x58C;
    static inline types::offset<float> current_rotation_offset = 0x558;
    static inline types::offset<float> aiming_rotation_offset = 0x55C;
    static inline types::offset<types::vector_3d> speed_offset = 0x44;
    static inline types::offset<flags_t> flags_offset = 0x46C;
    static inline types::offset<std::uint8_t> target_state_offset = 0x528;
    static inline types::offset<std::uintptr_t> weapons_offset = 0x5A0;
    static inline types::offset<std::uint8_t> current_weapon_slot_offset = 0x718;
public:
    bool is_in_the_air() const;
    bool is_targeting() const;

    types::meter_per_second_t get_speed() const;
    types::vector_3d get_bone_bosition(const bone& bone_id) const;

    weapon get_current_weapon() const;
    vehicle get_vehicle() const;
    static ped get_player() noexcept;
    
    void jump_into_vehicle(const vehicle& vehicle) const;
    void teleport(const types::vector_3d& pos) const override;
    void set_heading(float angle) const override;

    using placeable::placeable;
private:
    static constexpr std::ptrdiff_t weapon_size = 0x1C;
}; // class ped

} // namespace game
} // namespace plugin

#endif // GADMIN_PLUGIN_GAME_PED_H
