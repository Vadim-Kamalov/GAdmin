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

#ifndef GADMIN_PLUGIN_TYPES_SINGLETON_H
#define GADMIN_PLUGIN_TYPES_SINGLETON_H

#include <type_traits>
#include <utility>

namespace plugin::types {

/// Template class implementing singleton pattern. Provides thread-safe, lazy
/// initialization of single instance. Instance is created on first call to
/// `instance()` and persists until plugin termination.
///
/// @tparam T Type of singleton class to manage.
template<typename T>
class singleton {
public:
    virtual ~singleton() = default;

    /// Get singleton instance. Creates instance on first call if not
    /// already created. Forward all arguments to constructor of type T.
    ///
    /// @tparam Args    Types of constructor arguments.
    /// @param args[in] Constructor arguments to forward.
    /// @return         Reference to singleton instance.
    template<typename... Args> requires std::is_constructible_v<T, Args...>
    static auto instance(Args&&... args) noexcept -> T& {
        static auto instance = T(std::forward<Args>(args)...);
        return instance;
    }
}; // class singleton

} // namespace plugin::types

#endif // GADMIN_PLUGIN_TYPES_SINGLETON_H
