#include "plugin/samp/core/vehicle_pool.h"
#include "plugin/samp/core/net_game.h"
#include "plugin/samp/samp.h"

std::uintptr_t
plugin::samp::vehicle_pool::get() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x1170, 0x1170, 0x1180, 0x1180 };
    return reinterpret_cast<signatures::get_vehicle_pool_t>(base(offsets))(net_game::instance());
}

std::uintptr_t*
plugin::samp::vehicle_pool::get_objects() noexcept {
    return reinterpret_cast<std::uintptr_t*>(get() + 0x1134);
}

bool
plugin::samp::vehicle_pool::is_available(std::uint16_t id) noexcept {
    auto game_objects = reinterpret_cast<std::uintptr_t*>(get() + 0x4FB4);
    auto objects = get_objects();
    auto not_empty = reinterpret_cast<int*>(get() + 0x3074);

    return not_empty[id] == 1 && objects[id] != 0 && game_objects[id] != 0;
}

std::expected<plugin::samp::vehicle, plugin::samp::vehicle_pool::error>
plugin::samp::vehicle_pool::get_vehicle(std::uint16_t id) noexcept {
    if (!is_available(id))
        return std::unexpected(error::vehicle_not_available);

    return vehicle(get_objects()[id]);
}

std::expected<std::uint16_t, plugin::samp::vehicle_pool::error>
plugin::samp::vehicle_pool::get_id(const vehicle& vehicle) noexcept {
    for (std::uint16_t id = 0; id < max_vehicles; id++)
        if (get_vehicle(id) == vehicle)
            return id;

    return std::unexpected(error::vehicle_not_found);
}
