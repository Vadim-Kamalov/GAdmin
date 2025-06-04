#include "plugin/samp/core/ped.h"

auto plugin::samp::ped::get_game_ped() const -> game::ped {
    return game_ped.read(*handle);
}
