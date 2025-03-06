#ifndef GADMIN_PLUGIN_SAMP_CORE_VEHICLE_POOL_H
#define GADMIN_PLUGIN_SAMP_CORE_VEHICLE_POOL_H

#include "plugin/samp/core/vehicle.h"
#include "plugin/types/address.h"
#include <cstdint>
#include <expected>

namespace plugin {
namespace signatures {

using get_vehicle_pool_t = std::uintptr_t(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

class vehicle_pool {
public:
    enum class error { vehicle_not_found, vehicle_not_available };
private:
    static inline types::offset<std::uintptr_t*> objects_offset = 0x1134;
    static inline types::offset<std::uintptr_t*> game_objects_offset = 0x4FB4;
    static inline types::offset<int*> not_empty_offset = 0x3074;
    static types::versioned_address_container<signatures::get_vehicle_pool_t> get_vehicle_pool_container; 
public:
    static constexpr std::uint16_t max_vehicles = 2000;

    static std::expected<vehicle, error> get_vehicle(std::uint16_t id) noexcept;
    static std::expected<std::uint16_t, error> get_id(const vehicle& vehicle) noexcept;

    static bool is_available(std::uint16_t id) noexcept;
}; // class vehicle_pool

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_VEHICLE_POOL_H
