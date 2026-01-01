/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2026 The Contributors.
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

#ifndef GADMIN_PLUGIN_TYPES_SETTER_H
#define GADMIN_PLUGIN_TYPES_SETTER_H

#include <concepts>
#include <memory>
#include <variant>

namespace plugin::types {

/// Base class for setter proxy objects. Provides interface for proxy
/// objects that need to implement dereference and assignment operations.
///
/// @tparam T Type of value being proxied.
template<typename T>
class setter_proxy {
public:
    constexpr virtual ~setter_proxy() = default;

    /// Get proxied value.
    ///
    /// @return Proxied value of type T.
    constexpr virtual auto operator*() const -> T = 0;
    
    /// Set proxied value.
    ///
    /// @param value[in] Value to set.
    constexpr virtual auto operator=(const T& value) -> void = 0;
}; // class setter_proxy

/// Type alias for shared pointer to setter_proxy.
///
/// @tparam T Type of value being proxied.
template<typename T>
using setter_proxy_ptr_t = std::shared_ptr<setter_proxy<T>>;

/// Class providing unified interface for setting values.
/// Can work with both direct references and proxy objects.
///
/// @tparam T Type of value being managed.
template<typename T>
class setter final {
public:
    /// Type alias for proxy pointer.
    using proxy_t = setter_proxy_ptr_t<T>;
private:
    std::variant<T*, proxy_t> value;
public:
    /// Reset value to new value.
    ///
    /// @param new_value[in] Value to set.
    auto reset(const T& new_value) -> void;

    /// Get current value.
    ///
    /// @return Current value of type T.
    auto get() const -> T;

    /// Create setter from proxy object.
    ///
    /// @tparam derived_proxy Type of proxy object.
    /// @param proxy[in]      Proxy object to use.
    /// @return               `setter` object initialized with proxy.
    template<std::derived_from<setter_proxy<T>> derived_proxy>
    static auto from_proxy(const derived_proxy& proxy) noexcept -> setter {
        return setter(std::make_shared<derived_proxy>(proxy));
    }

    /// Set new value. Same as `setter::reset`, but
    /// as the operator function.
    ///
    /// @param new_value[in] New value to set.
    auto operator=(const T& new_value) -> void;

    /// Boolean conversion operator for bool type.
    ///
    /// @return Current boolean value.
    explicit operator bool() const requires(std::is_same_v<T, bool>);

    /// Get current value. Same as `setter::get()`,
    /// but as the operator function.
    ///
    /// @return Current value of type T.
    auto operator*() const -> T;

    /// Construct setter from proxy pointer.
    ///
    /// @param proxy[in] Proxy pointer to use.
    explicit setter(const proxy_t& proxy)
        : value(std::move(proxy)) {}

    /// Construct setter from direct reference.
    ///
    /// @param value[out] Reference to value to manage.
    explicit setter(T& value)
        : value(std::addressof(value)) {}
}; // class setter final

} // namespace plugin::types

template<typename T>
auto plugin::types::setter<T>::reset(const T& new_value) -> void {
    if (std::holds_alternative<T*>(value)) {
        *std::get<T*>(value) = new_value;
        return;
    }

    (*std::get<proxy_t>(value)) = new_value;
}

template<typename T>
auto plugin::types::setter<T>::get() const -> T {
    if (std::holds_alternative<T*>(value))
        return *std::get<T*>(value);

    return **std::get<proxy_t>(value);
}

template<typename T>
auto plugin::types::setter<T>::operator*() const -> T {
    return get();
}

template<typename T>
auto plugin::types::setter<T>::operator=(const T& new_value) -> void {
    reset(new_value);
}

template<typename T>
plugin::types::setter<T>::operator bool() const requires(std::is_same_v<T, bool>) {
    return get();
}

#endif // GADMIN_PLUGIN_TYPES_SETTER_H
