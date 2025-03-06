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

class remote_player {
private:
    types::dynamic_address<std::uintptr_t> handle = 0;

    static types::versioned_address_container<ped, types::version_container_option::offsets> ped_container;
    static types::versioned_address_container<vehicle, types::version_container_option::offsets> vehicle_container;
    static types::versioned_address_container<float, types::version_container_option::offsets> armor_container;
    static types::versioned_address_container<signatures::get_color_as_argb> get_color_container;
public:
    bool is_available() const;

    ped get_ped() const;
    vehicle get_vehicle() const;
    float get_armor() const;
    types::color get_color() const;

    explicit remote_player(const types::dynamic_address<std::uintptr_t>& handle)
        : handle(handle) {}

    remote_player() = default;
}; // class remote_player

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_REMOTE_PLAYER_H
