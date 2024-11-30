#ifndef GADMIN_PLUGIN_UTILS_H
#define GADMIN_PLUGIN_UTILS_H

#include <memory>
#include <print>

namespace plugin::utils {

template<typename T0, typename... Ts>
constexpr bool is_one_of = std::disjunction_v<std::is_same<T0, Ts>...>;

template<typename T>
concept smart_pointer = is_one_of<T, std::unique_ptr<typename T::element_type>, std::shared_ptr<typename T::element_type>>;

template <typename T>
concept comparable_to_nullptr = requires(T t) {
    { t != nullptr } -> std::convertible_to<bool>;
}; // concept comparable_to_nullptr

template<typename T>
using value_or_reference_return_t = std::conditional_t<
    sizeof(T) < 2 * sizeof(void*) && std::is_trivially_copy_constructible_v<T>, const T, const T&>;

template <comparable_to_nullptr T>
class not_null {
private:
    T ptr;
public:
    using element_type = T;

    template <typename U> requires std::convertible_to<U, T>
    constexpr not_null(U&& u) noexcept(std::is_nothrow_move_constructible_v<T>) : ptr(std::forward<U>(u)) {
        if (ptr == nullptr) {
            std::println(stderr, "not_null: nullptr is not allowed");
            std::exit(EXIT_FAILURE);
        }
    }

    template <typename U> requires std::convertible_to<U, T>
    constexpr not_null(const not_null<U>& other) noexcept(std::is_nothrow_move_constructible_v<T>)
        : not_null(other.get()) {}

    not_null(const not_null& other) = default;
    not_null& operator=(const not_null& other) = default;

    constexpr value_or_reference_return_t<T> get() const noexcept(noexcept(value_or_reference_return_t<T>{std::declval<T&>()})) {
        return ptr;
    }

    constexpr operator T() const { return get(); }
    constexpr decltype(auto) operator->() const { return get(); }
    constexpr decltype(auto) operator*() const { return *get(); }

    not_null(std::nullptr_t) = delete;
    not_null& operator=(std::nullptr_t) = delete;

    not_null& operator++() = delete;
    not_null& operator--() = delete;
    not_null operator++(int) = delete;
    not_null operator--(int) = delete;
    not_null& operator+=(std::ptrdiff_t) = delete;
    not_null& operator-=(std::ptrdiff_t) = delete;
    void operator[](std::ptrdiff_t) const = delete;
}; // class not_null

template<typename T>
concept pointer_like = comparable_to_nullptr<T> 
                       || smart_pointer<typename T::element_type> 
                       || std::is_same_v<T, not_null<typename T::element_type>>;

} // namespace plugin::utils

#endif // GADMIN_PLUGIN_UTILS_H
