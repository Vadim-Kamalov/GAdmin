#include "plugin/game/placeable.h"

auto plugin::game::placeable::is_locked() const -> bool {
    return physical_flags_offset.read(*handle).locked;
}

auto plugin::game::placeable::set_lock(bool state) const -> void {
    auto entity_flags = reinterpret_cast<int*>(*handle + *entity_flags_offset);
    auto physical_flags = reinterpret_cast<physical_flags_t*>(*handle + *physical_flags_offset);

    *entity_flags |= !state; // bool uses_collision
    physical_flags->locked = state;
    physical_flags->soft = state;
}

auto plugin::game::placeable::get_heading() const -> float {
    return clamp_angle(get_placeable_rotation(*handle) * rad_to_deg_multiplier);
}

auto plugin::game::placeable::set_heading_in_rad(float angle) const -> void {
    // SET_CHAR_HEADING (0x173) opcode implementation updates
    // entity RW's, but if **we** update that then it causes
    // problems in changing coordinates, so we ignore it.
    set_placeable_heading(*handle, angle);
}

auto plugin::game::placeable::set_heading_in_deg(float angle) const -> void {
    set_heading_in_rad(clamp_angle(angle) * deg_to_rad_multiplier);
}

auto plugin::game::placeable::clamp_angle(float angle) const -> float {
    if (angle < 0)
        angle += 360;

    if (angle > 360)
        angle -= 360;

    return angle;
}

auto plugin::game::placeable::set_heading(float angle) const -> void {
    set_heading_in_deg(angle);
}
