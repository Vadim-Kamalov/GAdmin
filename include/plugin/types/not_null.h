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

#ifndef GADMIN_PLUGIN_TYPES_NOT_NULL_H
#define GADMIN_PLUGIN_TYPES_NOT_NULL_H

#include <cassert>
#include <concepts>
#include <utility>

namespace plugin {
namespace concepts {

template <typename T>
concept comparable_to_nullptr = requires(T t) {
    { t != nullptr } -> std::convertible_to<bool>;
}; // concept comparable_to_nullptr

template<typename T>
using value_or_reference_return_t = std::conditional_t<
    sizeof(T) < 2 * sizeof(void*) && std::is_trivially_copy_constructible_v<T>, const T, const T&>;

} // namespace concepts

namespace types {

template<concepts::comparable_to_nullptr T>
class not_null final {
private:
    T ptr;
public:
    using element_type = T;

    template <typename U> requires std::convertible_to<U, T>
    constexpr not_null(U&& u) noexcept(std::is_nothrow_move_constructible_v<T>) : ptr(std::forward<U>(u)) {
        assert(ptr != nullptr && "not_null: nullptr is not allowed");
    }

    template <typename U> requires std::convertible_to<U, T>
    constexpr not_null(const not_null<U>& other) noexcept(std::is_nothrow_move_constructible_v<T>)
        : not_null(other.get()) {}

    not_null(const not_null& other) = default;
    auto operator=(const not_null& other) -> not_null& = default;

    constexpr auto get() const noexcept(noexcept(concepts::value_or_reference_return_t<T>(std::declval<T&>())))
        -> concepts::value_or_reference_return_t<T>
    {
        return ptr;
    }

    constexpr operator T() const { return get(); }
    constexpr auto operator->() const { return get(); }
    constexpr auto operator*() const { return *get(); }

    not_null(std::nullptr_t) = delete("construction with null pointer is not allowed");
    auto operator=(std::nullptr_t) -> not_null& = delete("null pointer assigning is not allowed");

    auto operator++() -> not_null& = delete("unwanted operator: pointers only point to single objects");
    auto operator--() -> not_null& = delete("unwanted operator: pointers only point to single objects");
    auto operator++(int) -> not_null = delete("unwanted operator: pointers only point to single objects");
    auto operator--(int) -> not_null = delete("unwanted operator: pointers only point to single objects");
    auto operator+=(std::ptrdiff_t) -> not_null& = delete("unwanted operator: pointers only point to single objects");
    auto operator-=(std::ptrdiff_t) -> not_null& = delete("unwanted operator: pointers only point to single objects");
    auto operator[](std::ptrdiff_t) const -> void = delete("unwanted operator: pointers only point to single objects");
}; // class not_null final

} // namespace types
} // namespace plugin

#endif // GADMIN_PLUGIN_TYPES_NOT_NULL_H
