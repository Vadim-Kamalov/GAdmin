#include "plugin/game/game.h"
#include "plugin/types/address.h"

std::pair<float, float>
plugin::game::get_screen_resolution() noexcept {
    static types::address<int> resolution_x = 0xC9C040;
    static types::address<int> resolution_y = 0xC9C044;
    return std::make_pair(resolution_x.read(), resolution_y.read());
}
