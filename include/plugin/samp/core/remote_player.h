#ifndef GADMIN_PLUGIN_SAMP_CORE_REMOTE_PLAYER_H
#define GADMIN_PLUGIN_SAMP_CORE_REMOTE_PLAYER_H

#include "plugin/samp/core/ped.h"
#include "plugin/samp/core/vehicle.h"
#include "plugin/types/address.h"
#include "plugin/types/color.h"

namespace plugin {
namespace signatures {

using get_color_as_argb = std::uint32_t(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

class remote_player final {
private:
    types::dynamic_address<std::uintptr_t> handle = 0;

    static types::versioned_address_container<ped, types::version_container_option::offsets> ped_container;
    static types::versioned_address_container<vehicle, types::version_container_option::offsets> vehicle_container;
    static types::versioned_address_container<float, types::version_container_option::offsets> armor_container;
    static types::versioned_address_container<signatures::get_color_as_argb> get_color_container;
    static types::versioned_address_container<std::uint16_t, types::version_container_option::offsets> id_container;
public:
    auto is_available() const -> bool;

    auto get_ped() const -> ped;
    auto get_vehicle() const -> vehicle;
    auto get_armor() const -> float;
    auto get_color() const -> types::color;
    auto get_id() const -> std::uint16_t;

    explicit remote_player(const types::dynamic_address<std::uintptr_t>& handle)
        : handle(handle) {}

    remote_player() = default;
}; // class remote_player final

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_REMOTE_PLAYER_H
