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

#ifndef GADMIN_PLUGIN_TYPES_ADDRESS_H
#define GADMIN_PLUGIN_TYPES_ADDRESS_H

#include "plugin/samp/samp.h"
#include <cstdint>
#include <type_traits>
#include <utility>

namespace plugin::types {

/// Represents different options for version container behavior.
enum class version_container_option {
    offsets, ///< Container stores raw offsets (no base address added).
    add_base ///< Container stores offsets with base address added.
}; // enum class version_container_option

/// Represents different types of memory addresses.
enum class address_type {
    static_t, ///< Static address that cannot be null.
    dynamic,  ///< Dynamic address that can change.
    offset    ///< Address representing an offset from a base.
}; // enum class address_type 

/// Template class (wrapper) representing a memory address with type-safe operations.
///
/// @tparam T    Type of data stored at the address.
/// @tparam type Type of address (static, dynamic, or offset).
template<typename T, address_type type = address_type::static_t>
class basic_address final {
private:
    std::uintptr_t pointer;
public:
    /// Get the raw pointer value of the address.
    ///
    /// @return Raw pointer value as `std::uintptr_t`.
    inline auto get() const -> std::uintptr_t;

    /// Check if the address is available (non-zero for dynamic addresses).
    ///
    /// @return True if the address is available.
    inline auto is_available() const -> bool;

    /// Read a value from the address with optional offset.
    ///
    /// @param offset[in] Offset from the base address (default: 0x0).
    /// @return           Value read from the address.
    inline auto read(std::uintptr_t offset = 0x0) const -> T;
    
    /// Write a value to the address with optional offset.
    ///
    /// @param value[in] Value to write to the address.
    /// @param offset[in] Offset from the base address (default: 0x0).
    inline auto write(auto value, std::uintptr_t offset = 0x0) const -> void;

    /// Invoke a callable at the address with forwarded arguments.
    /// 
    /// @note           Only available if `std::is_invocable_v<T, Args...>`.
    /// @tparam Args    Types of arguments to forward.
    /// @param args[in] Arguments to forward to the callable.
    /// @return         Result of the callable invocation.
    template<typename... Args>
    inline auto invoke(Args&&... args) const
        -> std::invoke_result_t<T, Args...> requires std::is_invocable_v<T, Args...>
    {
        return reinterpret_cast<T>(pointer)(std::forward<Args>(args)...);
    }

    /// Invoke a callable at the address with forwarded arguments. Same as
    /// `basic_address<T, address_type>::invoke` but as the operator function.
    /// 
    /// @note           Only available if `std::is_invocable_v<T, Args...>`.
    /// @tparam Args    Types of arguments to forward.
    /// @param args[in] Arguments to forward to the callable.
    /// @return         Result of the callable invocation.
    template<typename... Args>
    inline auto operator()(Args&&... args) const
        -> std::invoke_result_t<T, Args...> requires std::is_invocable_v<T, Args...>
    {
        return invoke(std::forward<Args>(args)...);
    }

    /// Add an offset to the address.
    ///
    /// @param other[in] Offset to add.
    /// @return          New address with the offset applied.
    auto operator+(std::uintptr_t other) const -> basic_address;

    /// Add another address to this address.
    ///
    /// @param other[in] Address to add.
    /// @return          New address with the sum of pointers.
    auto operator+(const basic_address& other) const -> basic_address;
    
    /// Add an offset to the current address in-place.
    ///
    /// @param other[in] Offset to add.
    /// @return          Reference to the current address after addition.
    auto operator+=(std::uintptr_t other) -> basic_address&;

    /// Add another address to the curent address in-place.
    ///
    /// @param other[in] Address to add.
    /// @return          Reference to the current address after addition.
    auto operator+=(const basic_address& other) -> basic_address&;

    /// Check if the current address is equal to a raw pointer.
    ///
    /// @param other[in] Raw pointer to compare with.
    /// @return          True if the current address and a raw pointer are equal.
    inline auto operator==(std::uintptr_t other) const -> bool;

    /// Check if the current address is equal to another address.
    ///
    /// @param other[in] Address to compare with.
    /// @return          True if the addresses are equal.
    inline auto operator==(const basic_address& other) const -> bool;
    
    /// Get the raw pointer value of the address. Same as
    /// `basic_address<T, address_type>::get` but as the
    /// operator function.
    ///
    /// @return Raw pointer value as `std::uintptr_t`.
    inline auto operator*() const -> std::uintptr_t;

    /// Check if the address is available (non-zero for dynamic addresses). Same as
    /// `basic_address<T, address_type>::is_available` but as the operator function.
    ///
    /// @return True if the address is available.
    inline explicit operator bool() const;

    /// Construct a basic_address from a raw pointer.
    ///
    /// @param pointer[in] Raw pointer value to initialize the address.
    basic_address(std::uintptr_t pointer)
        : pointer(pointer) {}

    /// Deleted constructor with `std::nullptr_t` parameter for static addresses.
    basic_address(std::nullptr_t) requires(type == address_type::static_t)
        = delete("Static address cannot be constructed with the null pointer");

    /// Deleted assign operator with `std::nullptr_t` parameter for static addresses.
    basic_address& operator=(std::nullptr_t) requires(type == address_type::static_t)
        = delete("Static address cannot be assigned to the null pointer");
}; // class basic_address final

/// Container for SA:MP version-specific addresses with optional base address handling.
/// Size of the container is limited to the count of available SA:MP versions.
///
/// @tparam T      Type of data stored at the addresses.
/// @tparam option Whether to add base address to offsets (default: add_base).
template<typename T, version_container_option option = version_container_option::add_base>
class versioned_address_container final {
public:
    /// Type alias for the contained address items.
    using item_t = basic_address<T>;
private:
    static constexpr std::size_t container_size = std::to_underlying(samp::version::count) - 2;
    
    bool added_base = false;
    std::array<item_t, container_size> container;
public:
    /// Access address in the container based on the current SA:MP version with
    /// the base added if `option == version_container_option::add_base`.
    ///
    /// @return Reference to the address based on the current SA:MP version.
    auto operator*() -> item_t&;

    /// Access address in the container based on the current SA:MP version with
    /// the base added if `option == version_container_option::add_base`.
    ///
    /// @return Pointer to the address based on the current SA:MP version.
    auto operator->() -> item_t*;

    /// Construct a container with addresses for each version.
    ///
    /// @tparam Args    Types of arguments (must match `container_size`).
    /// @param args[in] Addresses for each available version..
    template<typename... Args> requires(sizeof...(Args) == container_size)
    versioned_address_container(Args&&... args) : container({ std::forward<Args>(args)... }) {}
}; // class versioned_address_container final

/// Convenience alias for a static memory address.
///
/// Represents a fixed memory address that cannot be null. Use this for
/// addresses that are guaranteed to be valid throughout plugin execution.
///
/// @tparam T Type of data stored at the address.
template<typename T>
using address = basic_address<T, address_type::static_t>;

/// Convenience alias for a dynamic memory address.
///
/// Represents a memory address that can change or be invalid (null).
/// Use this for addresses that may become unavailable during runtime.
///
/// @tparam T Type of data stored at the address.
template<typename T>
using dynamic_address = basic_address<T, address_type::dynamic>;

/// Convenience alias for a memory offset.
///
/// Represents an offset from a base address that needs to be added
/// to a base pointer before use. Use this while calculating offsets.
///
/// @tparam T Type of data stored at the calculated address.
template<typename T>
using offset = basic_address<T, address_type::offset>;

} // namespace plugin::types

template<typename T, plugin::types::address_type type>
inline auto plugin::types::basic_address<T, type>::get() const -> std::uintptr_t {
    return pointer;
}

template<typename T, plugin::types::address_type type>
inline auto plugin::types::basic_address<T, type>::is_available() const -> bool {
    return pointer != 0;
}

template<typename T, plugin::types::address_type type>
inline plugin::types::basic_address<T, type>::operator bool() const {
    return is_available();
}

template<typename T, plugin::types::address_type type>
inline auto plugin::types::basic_address<T, type>::read(std::uintptr_t offset) const -> T {
    if constexpr (std::is_constructible_v<T, basic_address<std::uintptr_t, address_type::dynamic>>)
        return T(*reinterpret_cast<std::uintptr_t*>(pointer + offset));
    else if constexpr (std::is_pointer_v<T>)
        return reinterpret_cast<T>(pointer + offset);
    else
        return *reinterpret_cast<T*>(pointer + offset);
}

template<typename T, plugin::types::address_type type>
inline auto plugin::types::basic_address<T, type>::write(auto value, std::uintptr_t offset) const -> void {
    *reinterpret_cast<T*>(pointer + offset) = value;
}

template<typename T, plugin::types::address_type type>
auto plugin::types::basic_address<T, type>::operator+(std::uintptr_t other) const -> basic_address {
    return basic_address(pointer + other);
} 

template<typename T, plugin::types::address_type type>
auto plugin::types::basic_address<T, type>::operator+(const basic_address& other) const -> basic_address {
    return basic_address(pointer + *other);
}

template<typename T, plugin::types::address_type type>
auto plugin::types::basic_address<T, type>::operator+=(std::uintptr_t other) -> basic_address& {
    pointer += other;
    return *this;
} 

template<typename T, plugin::types::address_type type>
auto plugin::types::basic_address<T, type>::operator+=(const basic_address& other) -> basic_address& {
    pointer += *other;
    return *this;
}

template<typename T, plugin::types::address_type type>
inline auto plugin::types::basic_address<T, type>::operator==(const basic_address& other) const -> bool {
    return *this == *other;
} 

template<typename T, plugin::types::address_type type>
inline auto plugin::types::basic_address<T, type>::operator==(std::uintptr_t other) const -> bool {
    return *this == other;
}

template<typename T, plugin::types::address_type type>
inline auto plugin::types::basic_address<T, type>::operator*() const -> std::uintptr_t {
    return get();
}

template<typename T, plugin::types::version_container_option option>
auto plugin::types::versioned_address_container<T, option>::operator*() -> item_t& {
    item_t& item = container[std::to_underlying(samp::get_version()) - 2];

    if constexpr (option == version_container_option::add_base) {
        if (!added_base) {
            item += samp::get_base();
            added_base = true;
        }
    }
    
    return item;
}

template<typename T, plugin::types::version_container_option option>
auto plugin::types::versioned_address_container<T, option>::operator->() -> item_t* {
    return &this->operator*();
}

#endif // GADMIN_PLUGIN_TYPES_ADDRESS_H
