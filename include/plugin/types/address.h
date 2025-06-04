#ifndef GADMIN_PLUGIN_TYPES_ADDRESS_H
#define GADMIN_PLUGIN_TYPES_ADDRESS_H

#include "plugin/samp/samp.h"
#include <cstdint>
#include <type_traits>
#include <utility>

namespace plugin::types {

enum class version_container_option { offsets, add_base };
enum class address_type { static_t, dynamic, offset };

template<typename T, address_type type = address_type::static_t>
class basic_address final {
private:
    std::uintptr_t pointer;
public:
    inline auto get() const -> std::uintptr_t;
    inline auto is_available() const -> bool;

    inline auto read(std::uintptr_t offset = 0x0) const -> T;
    inline auto write(auto value, std::uintptr_t offset = 0x0) const -> void;

    template<typename... Args>
    inline auto invoke(Args&&... args) const
        -> std::invoke_result_t<T, Args...> requires std::is_invocable_v<T, Args...>
    {
        return reinterpret_cast<T>(pointer)(std::forward<Args>(args)...);
    }

    template<typename... Args>
    inline auto operator()(Args&&... args) const
        -> std::invoke_result_t<T, Args...> requires std::is_invocable_v<T, Args...>
    {
        return invoke(std::forward<Args>(args)...);
    }

    auto operator+(std::uintptr_t other) const -> basic_address;
    auto operator+(const basic_address& other) const -> basic_address;
    
    auto operator+=(std::uintptr_t other) -> basic_address&;
    auto operator+=(const basic_address& other) -> basic_address&;

    inline auto operator==(const basic_address& other) const -> bool;
    inline auto operator==(std::uintptr_t other) const -> bool;
    
    inline auto operator*() const -> std::uintptr_t;
    inline explicit operator bool() const;

    basic_address(std::nullptr_t) requires(type == address_type::static_t) = delete;
    basic_address& operator=(std::nullptr_t) requires(type == address_type::static_t) = delete;

    basic_address(std::uintptr_t pointer)
        : pointer(pointer) {}
}; // class basic_address final

template<typename T, version_container_option option = version_container_option::add_base>
class versioned_address_container final {
public:
    using item_t = basic_address<T>;
private:
    static constexpr std::size_t container_size = std::to_underlying(samp::version::count) - 2;
    
    bool added_base = false;
    std::array<item_t, container_size> container;
public:
    auto operator*() -> item_t&;
    auto operator->() -> item_t*;

    template<typename... Args> requires(sizeof...(Args) == container_size)
    versioned_address_container(Args&&... args) : container({ std::forward<Args>(args)... }) {}
}; // class versioned_address_container final

template<typename T>
using address = basic_address<T, address_type::static_t>;

template<typename T>
using dynamic_address = basic_address<T, address_type::dynamic>;

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
