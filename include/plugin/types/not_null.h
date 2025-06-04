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

    not_null(std::nullptr_t) = delete;
    auto operator=(std::nullptr_t) -> not_null& = delete;

    auto operator++() -> not_null& = delete;
    auto operator--() -> not_null& = delete;
    auto operator++(int) -> not_null = delete;
    auto operator--(int) -> not_null = delete;
    auto operator+=(std::ptrdiff_t) -> not_null& = delete;
    auto operator-=(std::ptrdiff_t) -> not_null& = delete;
    auto operator[](std::ptrdiff_t) const -> void = delete;
}; // class not_null final

} // namespace types
} // namespace plugin

#endif // GADMIN_PLUGIN_TYPES_NOT_NULL_H
