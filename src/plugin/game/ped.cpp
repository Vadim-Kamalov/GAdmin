#include "plugin/game/ped.h"
#include <cmath>

bool
plugin::game::ped::is_in_the_air() const {
    return flags_offset.read(*handle).in_the_air;
}

plugin::types::meter_per_second_t
plugin::game::ped::get_speed() const {
    types::vector_3d speed = speed_offset.read(*handle);
    return std::ceil(speed.magnitude() * 50);
}

plugin::types::vector_3d
plugin::game::ped::get_bone_bosition(const bone& bone_id) const {
    types::vector_3d result;
    get_bone_position_address(*handle, &result, std::to_underlying(bone_id), false);
    return result;
}

plugin::game::ped
plugin::game::ped::get_player() noexcept {
    return player_address.read();
}

plugin::game::vehicle
plugin::game::ped::get_vehicle() const {
    if (!flags_offset.read(*handle).in_vehicle)
        return vehicle(0);

    return vehicle_offset.read(*handle);
}

void
plugin::game::ped::jump_into_vehicle(const vehicle& vehicle) const {
    static types::address<signatures::task_process_ped> process_ped = 0x64B950;
    
    // Creates a new `CTaskSimpleCarSetPedInAsDriver` task and sets
    // the vehicle pointer to the passed one. Then, it calls a member function
    // to process the ped. The call is safe because `process_ped` does not
    // modify/read any member-pointers of the structure (except `target_vehicle`).
    
    struct {
        std::uint32_t _;
        std::uint32_t _;
        std::uint32_t _;
        std::uint32_t _;
        std::uintptr_t target_vehicle;
        std::uint32_t _;
        std::uint16_t _;
    } set_ped_in_as_driver_task = {
        .target_vehicle = *vehicle.handle
    };

    process_ped(reinterpret_cast<std::uintptr_t>(&set_ped_in_as_driver_task), *handle);
}

void
plugin::game::ped::teleport(const types::vector_3d& pos) const {
    auto flags = reinterpret_cast<flags_t*>(*handle + *flags_offset);
    
    flags->is_standing = true;
    flags->was_standing = true;

    set_coordinates(pos);
}

void
plugin::game::ped::set_heading(float angle) const {
    angle = clamp_angle(angle) * deg_to_rad_multiplier;
    
    current_rotation_offset.write(angle, *handle);
    aiming_rotation_offset.write(angle, *handle);

    set_heading_in_rad(angle);
}
