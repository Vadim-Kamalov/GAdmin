#include "plugin/samp/core/vehicle_pool.h"
#include "plugin/samp/core/net_game.h"

plugin::types::versioned_address_container<plugin::signatures::get_vehicle_pool_t>
plugin::samp::vehicle_pool::get_vehicle_pool_container = { 0x1170, 0x1170, 0x1180, 0x1180 };

bool
plugin::samp::vehicle_pool::is_available(std::uint16_t id) noexcept {
    std::uintptr_t pool = get_vehicle_pool_container->invoke(net_game::instance_container->read());
    std::uintptr_t* game_objects = game_objects_offset.read(pool);
    std::uintptr_t* objects = objects_offset.read(pool);
    int* not_empty = not_empty_offset.read(pool);

    return not_empty[id] == 1 && objects[id] != 0 && game_objects[id] != 0;
}

std::expected<plugin::samp::vehicle, plugin::samp::vehicle_pool::error>
plugin::samp::vehicle_pool::get_vehicle(std::uint16_t id) noexcept {
    if (!is_available(id))
        return std::unexpected(error::vehicle_not_available);

    return vehicle(objects_offset.read(net_game::instance_container->read())[id]);
}

std::expected<std::uint16_t, plugin::samp::vehicle_pool::error>
plugin::samp::vehicle_pool::get_id(const vehicle& vehicle) noexcept {
    for (std::uint16_t id = 0; id < max_vehicles; id++)
        if (get_vehicle(id) == vehicle)
            return id;

    return std::unexpected(error::vehicle_not_found);
}
