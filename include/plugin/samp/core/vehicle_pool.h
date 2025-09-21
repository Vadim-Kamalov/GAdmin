/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_SAMP_CORE_VEHICLE_POOL_H
#define GADMIN_PLUGIN_SAMP_CORE_VEHICLE_POOL_H

#include "plugin/samp/core/vehicle.h"
#include "plugin/types/address.h"
#include <cstdint>
#include <deque>
#include <expected>

namespace plugin {
namespace signatures {

using get_vehicle_pool_t = std::uintptr_t(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

/// Provides methonds for searching in the SA:MP vehicle pool.
class vehicle_pool final {
private:
    static inline types::offset<std::uintptr_t*> objects_offset = 0x1134;
    static inline types::offset<std::uintptr_t*> game_objects_offset = 0x4FB4;
    static inline types::offset<int*> not_empty_offset = 0x3074;
    static types::versioned_address_container<signatures::get_vehicle_pool_t> get_vehicle_pool_container; 
    
    static auto is_available(std::uint16_t id) noexcept -> bool;
public:
    /// Possible error codes received from the methods in this class.
    enum class error : std::uint8_t {
        vehicle_not_found,    ///< Vehicle not found.
        vehicle_not_available ///< Vehicle is not available.
    }; // enum class error : std::uint8_t
    
    /// Maximum amount of the vehicles in the SA:MP vehicle pool.
    static constexpr std::uint16_t max_vehicles = 2000;
    
    /// Get vehicle instance by its ID.
    ///
    /// @param id[in] Vehicle's ID.
    /// @return       Vehicle instance if found, `vehicle_pool::error` otherwise.
    static auto get_vehicle(std::uint16_t id) noexcept -> std::expected<vehicle, error>;

    /// Get ID of the vehicle instance.
    ///
    /// @parma vehicle[in] Vehicle instance.
    /// @return            Vehicle's ID if found, `vehicle_pool::error` otherwise.
    static auto get_id(const vehicle& vehicle) noexcept -> std::expected<std::uint16_t, error>;
    
    /// Get vehicles in the current stream.
    ///
    /// @return Vector of the vehicles associated with theirs IDs.
    static auto get_stream() noexcept -> std::deque<std::pair<std::uint16_t, vehicle>>;
}; // class vehicle_pool final

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_VEHICLE_POOL_H
