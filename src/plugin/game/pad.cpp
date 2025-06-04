#include "plugin/game/pad.h"

auto plugin::game::pad::disable_player_control() noexcept -> void {
    disable_player_controls_offset.write(true, *instance);
}

auto plugin::game::pad::set_player_enter_vehicle(bool state) noexcept -> void {
    disable_player_enter_vehicle_offset.write(state, *instance);
}
