#include "plugin/game/placeable.h"

bool
plugin::game::placeable::is_locked() const {
    return physical_flags_offset.read(*handle).locked;
}

void
plugin::game::placeable::set_lock(bool state) const {
    auto entity_flags = reinterpret_cast<int*>(*handle + *entity_flags_offset);
    auto physical_flags = reinterpret_cast<physical_flags_t*>(*handle + *physical_flags_offset);

    *entity_flags |= !state; // bool uses_collision
    physical_flags->locked = state;
    physical_flags->soft = state;
}

float
plugin::game::placeable::get_heading() const {
    return clamp_angle(get_placeable_rotation(*handle) * rad_to_deg_multiplier);
}

void
plugin::game::placeable::set_heading_in_rad(float angle) const {
    // SET_CHAR_HEADING (0x173) opcode implementation updates
    // entity RW's, but if **we** update that then it causes
    // problems in changing coordinates, so we ignore it.
    set_placeable_heading(*handle, angle);
}

void
plugin::game::placeable::set_heading_in_deg(float angle) const {
    set_heading_in_rad(clamp_angle(angle) * deg_to_rad_multiplier);
}

float
plugin::game::placeable::clamp_angle(float angle) const {
    if (angle < 0)
        angle += 360;

    if (angle > 360)
        angle -= 360;

    return angle;
}

void
plugin::game::placeable::set_heading(float angle) const {
    set_heading_in_deg(angle);
}
