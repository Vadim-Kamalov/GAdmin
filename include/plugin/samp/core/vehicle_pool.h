#ifndef GADMIN_PLUGIN_SAMP_CORE_VEHICLE_POOL_H
#define GADMIN_PLUGIN_SAMP_CORE_VEHICLE_POOL_H

#include "plugin/samp/core/vehicle.h"
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
public:
    static constexpr std::uint16_t max_vehicles = 2000;

    static std::uintptr_t get() noexcept;
    static std::uintptr_t* get_objects() noexcept;

    static std::expected<vehicle, error> get_vehicle(std::uint16_t id) noexcept;
    static std::expected<std::uint16_t, error> get_id(const vehicle& vehicle) noexcept;

    static bool is_available(std::uint16_t id) noexcept;
}; // class vehicle_pool

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_VEHICLE_POOL_H
