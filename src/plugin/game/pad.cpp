#include "plugin/game/pad.h"

void
plugin::game::pad::disable_player_control() noexcept {
    disable_player_controls_offset.write(true, *instance);
}

void
plugin::game::pad::set_player_enter_vehicle(bool state) noexcept {
    disable_player_enter_vehicle_offset.write(state, *instance);
}
