#ifndef GADMIN_PLUGIN_TYPES_OPTIONS_H
#define GADMIN_PLUGIN_TYPES_OPTIONS_H

#include "plugin/types/setter.h"
#include <cstdint>
#include <numeric>
#include <type_traits>
#include <utility>

namespace plugin::types {

template<typename T> requires std::is_enum_v<T>
class options final {
public:
    using flags_t = std::underlying_type_t<T>;

    class const_iterator final {
    private:
        flags_t current, flags;
    public:
        using iterator_category = std::forward_iterator_tag;
        using difference_type = std::ptrdiff_t;
        using value_type = T;
        using pointer = const T*;
        using reference = const T&;

        constexpr auto operator++() -> const_iterator&;
        constexpr auto operator*() const -> T;
        constexpr auto operator==(const const_iterator& other) const -> bool;
    
        constexpr const_iterator(flags_t current, flags_t flags);
    }; // class const_iterator final
    
    class reference final : public setter_proxy<bool> {
    private:
        flags_t& flags;
        std::uint8_t bit_index;
    public:
        constexpr auto operator*() const -> bool override;
        constexpr auto operator=(const bool& value) -> void override;
        constexpr explicit reference(flags_t& flags, std::uint8_t bit_index)
            : flags(flags), bit_index(bit_index) {}
    }; // class reference final : public setter_proxy<bool>
private:
    constexpr auto initialize_flags(std::initializer_list<T> list) -> flags_t;
public:
    flags_t flags = 0;

    constexpr auto has_value(T flag) const -> bool;
    constexpr auto begin() const -> const_iterator;
    constexpr auto end() const -> const_iterator;

    constexpr auto operator[](std::uint8_t bit_index) const -> bool;
    constexpr auto operator[](std::uint8_t bit_index) -> reference;

    constexpr options(T flag)
        : flags(std::to_underlying(flag)) {}

    constexpr options(flags_t flags)
        : flags(flags) {}

    constexpr options(std::initializer_list<T> list)
        : flags(initialize_flags(list)) {}

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
