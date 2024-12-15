#include "plugin/game/game.h"

std::pair<float, float>
plugin::game::get_screen_resolution() noexcept {
    auto x = *reinterpret_cast<int*>(0xC9C040);
    auto y = *reinterpret_cast<int*>(0xC9C044);
    return std::make_pair(static_cast<float>(x), static_cast<float>(y));
}
