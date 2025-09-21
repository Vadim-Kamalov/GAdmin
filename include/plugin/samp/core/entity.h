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

#ifndef GADMIN_PLUGIN_SAMP_CORE_ENTITY_H
#define GADMIN_PLUGIN_SAMP_CORE_ENTITY_H

#include "plugin/types/address.h"

namespace plugin {
namespace signatures {

using get_model_index_t = int(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

/// Represents entity in the SA:MP client. Base class for `samp::ped` and `samp::vehicle`.
class entity {
private:
    static types::versioned_address_container<signatures::get_model_index_t> get_model_index_container;
    static inline types::offset<std::uintptr_t> game_handle = 0x40;
protected:
    /// Entity handle.
    types::dynamic_address<std::uintptr_t> handle;
public:
    /// Check if an entity pointer is not null. Equivalent to `handle.is_available()`.
    ///
    /// @return True if the entity pointer is not null;
    auto is_available() const -> bool;

    /// Get model index of the entity.
    ///
    /// @return Entity model index.
    auto get_model_index() const -> int;

    /// Check the equality of two entities. Equivalent to `handle == other.handle`.
    auto operator==(const entity& other) const -> bool;

    /// Construct entity class.
    /// 
    /// @param handle[in] Dynamic address handle for the entity.
    explicit entity(const types::dynamic_address<std::uintptr_t>& handle)
        : handle(handle) {}
}; // class entity

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_ENTITY_H
