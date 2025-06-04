#include "plugin/game/ped.h"
#include <cmath>

auto plugin::game::ped::is_in_the_air() const -> bool {
    return flags_offset.read(*handle).in_the_air;
}

auto plugin::game::ped::is_targeting() const -> bool {
    return target_state_offset.read(*handle) == 19;
}

auto plugin::game::ped::get_speed() const -> types::meter_per_second_t {
    types::vector_3d speed = speed_offset.read(*handle);
    return std::ceil(speed.magnitude() * 50);
}

auto plugin::game::ped::get_bone_bosition(const bone& bone_id) const -> types::vector_3d {
    types::vector_3d result;
    get_bone_position_address(*handle, &result, std::to_underlying(bone_id), false);
    return result;
}

auto plugin::game::ped::get_current_weapon() const -> weapon {
    auto weapons = weapons_offset.read(*handle);
    auto current_weapon_slot = current_weapon_slot_offset.read(*handle);
    auto current_weapon_type = *reinterpret_cast<int*>(weapons + current_weapon_slot * weapon_size);
    return static_cast<weapon>(current_weapon_type);
}

auto plugin::game::ped::get_player() noexcept -> ped {
    return player_address.read();
}

auto plugin::game::ped::get_vehicle() const -> vehicle {
    if (!flags_offset.read(*handle).in_vehicle)
        return vehicle(0);

    return vehicle_offset.read(*handle);
}

auto plugin::game::ped::jump_into_vehicle(const vehicle& vehicle) const -> void {
    static types::address<signatures::task_process_ped> process_ped = 0x64B950;
    
    // Creates a new `CTaskSimpleCarSetPedInAsDriver` task and sets
    // the vehicle pointer to the passed one. Then, it calls a member function
    // to process the ped. The call is safe because `process_ped` does not
    // modify/read any member-pointers of the structure (except `target_vehicle`).
    
    struct {
        std::uint32_t pad0;
        std::uint32_t pad1;
        std::uint32_t pad2;
        std::uint32_t pad3;
        std::uintptr_t target_vehicle;
        std::uint32_t pad4;
        std::uint16_t pad5;
    } set_ped_in_as_driver_task = {
        .target_vehicle = *vehicle.handle
    };

    process_ped(reinterpret_cast<std::uintptr_t>(&set_ped_in_as_driver_task), *handle);
}

auto plugin::game::ped::teleport(const types::vector_3d& pos) const -> void {
    auto flags = reinterpret_cast<flags_t*>(*handle + *flags_offset);
    
    flags->is_standing = true;
    flags->was_standing = true;

    set_coordinates(pos);
}

auto plugin::game::ped::set_heading(float angle) const -> void {
    angle = clamp_angle(angle) * deg_to_rad_multiplier;
    
    current_rotation_offset.write(angle, *handle);
    aiming_rotation_offset.write(angle, *handle);

    set_heading_in_rad(angle);
}
