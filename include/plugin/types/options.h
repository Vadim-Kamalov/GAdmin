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

#ifndef GADMIN_PLUGIN_TYPES_OPTIONS_H
#define GADMIN_PLUGIN_TYPES_OPTIONS_H

#include "plugin/types/setter.h"
#include <cstdint>
#include <numeric>
#include <type_traits>
#include <utility>

namespace plugin::types {

/// Container for managing bitmask options based on enum values.
///
/// Example usage:
/// 
/// ```cpp
/// using namespace plugin;
///
/// enum condition : std::uint8_t {
///     a = 1 << 0,
///     b = 1 << 1,
///     c = 1 << 2
/// }; // enum condition : std::uint8_t
///
/// static constexpr types::options<condition> conditions_a = { condition::a, condition::b };
/// static constexpr types::options<condition> conditions_b = condition::b;
/// 
/// static_assert(conditions_a.has_value(condition::a)) // true
/// static_assert(conditions_a[1]) // true
/// ```
///
/// @tparam T Enum type representing individual options/flags.
template<typename T> requires std::is_enum_v<T>
class options final {
public:
    using flags_t = std::underlying_type_t<T>; ///< Underlying flags storage type.

    /// Iterator type for enumerating set options.
    class const_iterator final {
    private:
        flags_t current, flags;
    public:
        using iterator_category = std::forward_iterator_tag; ///< Iterator category.
        using difference_type = std::ptrdiff_t;              ///< Difference type.
        using value_type = T;                                ///< Value type.
        using pointer = const T*;                            ///< Pointer type.
        using reference = const T&;                          ///< Reference type.

        /// Advance iterator to next set option.
        ///
        /// @return Reference to this iterator.
        constexpr auto operator++() -> const_iterator&;

        /// Get current option value.
        ///
        /// @return Current option value.
        constexpr auto operator*() const -> T;

        /// Compare this iterator with another.
        ///
        /// @param other[in] Iterator to compare with.
        /// @return          True if iterators point to same position.
        constexpr auto operator==(const const_iterator& other) const -> bool;

        /// Construct iterator.
        ///
        /// @param current[in] Current bit position.
        /// @param flags[in]   Flags containing set options.
        constexpr const_iterator(flags_t current, flags_t flags);
    }; // class const_iterator final
    
    /// Proxy reference for accessing individual bits.
    class reference final : public setter_proxy<bool> {
    private:
        flags_t& flags;
        std::uint8_t bit_index;
    public:
        /// Get boolean value of bit.
        ///
        /// @return True if bit is set.
        constexpr auto operator*() const -> bool override;

        /// Set bit value.
        ///
        /// @param value[in] Boolean value to set.
        constexpr auto operator=(const bool& value) -> void override;

        /// Construct reference proxy.
        ///
        /// @param flags[in]     Reference to flags storage.
        /// @param bit_index[in] Index of bit to reference.
        constexpr explicit reference(flags_t& flags, std::uint8_t bit_index)
            : flags(flags), bit_index(bit_index) {}
    }; // class reference final : public setter_proxy<bool>
private:
    constexpr auto initialize_flags(std::initializer_list<T> list) -> flags_t;
public:
    flags_t flags = 0; ///< Raw flags storage.

    /// Check if specific option is set.
    ///
    /// @param flag[in] Option to check.
    /// @return         True if option is set.
    constexpr auto has_value(T flag) const -> bool;

    /// Get iterator to first set option.
    ///
    /// @return Iterator pointing to first set option.
    constexpr auto begin() const -> const_iterator;

    /// Get iterator to end of options.
    ///
    /// @return Iterator pointing to end position.
    constexpr auto end() const -> const_iterator;

    /// Check if bit at specific index is set.
    ///
    /// @param bit_index[in] Index of bit to check.
    /// @return              True if bit is set.
    constexpr auto operator[](std::uint8_t bit_index) const -> bool;

    /// Get reference to bit at specific index.
    ///
    /// @param bit_index[in] Index of bit to reference.
    /// @return              Reference proxy for bit manipulation.
    constexpr auto operator[](std::uint8_t bit_index) -> reference;

    /// Construct options from single enum value.
    ///
    /// @param flag[in] Enum value to initialize with.
    constexpr options(T flag)
        : flags(std::to_underlying(flag)) {}

    /// Construct options from raw flags value.
    ///
    /// @param flags[in] Raw flags value to initialize with.
    constexpr options(flags_t flags)
        : flags(flags) {}

    /// Construct options from initializer list of enum values.
    ///
    /// @param list[in] Initializer list of enum values.
    constexpr options(std::initializer_list<T> list)
        : flags(initialize_flags(list)) {}

    /// Default constructor.
    constexpr options() = default;
}; // class options final

} // namespace plugin::types

template<typename T> requires std::is_enum_v<T>
constexpr auto plugin::types::options<T>::initialize_flags(std::initializer_list<T> list) -> flags_t {
    return std::accumulate(list.begin(), list.end(), 0, [](flags_t lhs, T rhs) {
        return lhs | std::to_underlying(rhs);
    });
}

template<typename T> requires std::is_enum_v<T>
constexpr auto plugin::types::options<T>::has_value(T flag) const -> bool {
    return (flags & std::to_underlying(flag)) != 0;
}

template<typename T> requires std::is_enum_v<T>
constexpr plugin::types::options<T>::const_iterator::const_iterator(flags_t current, flags_t flags)
    : current(current),
      flags(flags)
{
    if (current == 0 || !(flags & current))
        operator++();
}

template<typename T> requires std::is_enum_v<T>
constexpr auto plugin::types::options<T>::const_iterator::operator++() -> const_iterator& {
    do {
        current = static_cast<flags_t>(current << 1);
    } while (current && !(flags & current));
    return *this;
}

template<typename T> requires std::is_enum_v<T>
constexpr auto plugin::types::options<T>::const_iterator::operator*() const -> T {
    return static_cast<T>(current);
}

template<typename T> requires std::is_enum_v<T>
constexpr auto plugin::types::options<T>::const_iterator::operator==(const const_iterator& other) const -> bool {
    return current == other.current;
}

template<typename T> requires std::is_enum_v<T>
constexpr auto plugin::types::options<T>::begin() const -> const_iterator {
    return const_iterator(1, flags);
}

template<typename T> requires std::is_enum_v<T>
constexpr auto plugin::types::options<T>::end() const -> const_iterator {
    return const_iterator(0, flags);
}

template<typename T> requires std::is_enum_v<T>
constexpr auto plugin::types::options<T>::operator[](std::uint8_t bit_index) const -> bool {
    return (flags & (1 << bit_index)) != 0;
}

template<typename T> requires std::is_enum_v<T>
constexpr auto plugin::types::options<T>::operator[](std::uint8_t bit_index) -> reference {
    return reference(flags, bit_index);
}

template<typename T> requires std::is_enum_v<T>
constexpr auto plugin::types::options<T>::reference::operator*() const -> bool {
    return (flags & (1 << bit_index)) != 0;
}

template<typename T> requires std::is_enum_v<T>
constexpr auto plugin::types::options<T>::reference::operator=(const bool& value) -> void{
    if (value)
        flags |= (1 << bit_index);
    else
        flags &= ~(1 << bit_index);
}

#endif // GADMIN_PLUGIN_TYPES_OPTIONS_H
