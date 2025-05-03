#include "plugin/game/game.h"
#include "plugin/types/address.h"

static plugin::types::address<plugin::signatures::calc_screen_coords> calc_screen_coords = 0x71DAB0;

std::pair<float, float>
plugin::game::get_screen_resolution() noexcept {
    static types::address<int> resolution_x = 0xC9C040;
    static types::address<int> resolution_y = 0xC9C044;
    return { resolution_x.read(), resolution_y.read() };
}

plugin::types::vector_3d
plugin::game::convert_3d_coords_to_screen(const types::vector_3d& coords) noexcept {
    types::vector_3d result;

    // `signatures::calc_screen_coords` doesn't modify input pointer,
    // so it's safe to do `const_cast` for const reference here.
    if (!calc_screen_coords(const_cast<types::vector_3d*>(std::addressof(coords)), &result))
        return { 0, 0, 0 };

    return result;
}
