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
class basic_address {
private:
    std::uintptr_t pointer;
public:
    [[nodiscard]] inline std::uintptr_t get() const;

    [[nodiscard]] inline bool is_available() const;
    inline explicit operator bool() const;

    [[nodiscard]] inline T read(std::uintptr_t offset = 0x0) const;
    inline void write(auto value, std::uintptr_t offset = 0x0) const;

    template<typename... Args>
    inline std::invoke_result_t<T, Args...> invoke(Args&&... args) const requires std::is_invocable_v<T, Args...> {
        return reinterpret_cast<T>(pointer)(std::forward<Args>(args)...);
    }

    template<typename... Args>
    inline std::invoke_result_t<T, Args...> operator()(Args&&... args) const requires std::is_invocable_v<T, Args...> {
        return invoke(std::forward<Args>(args)...);
    }

    [[nodiscard]] basic_address operator+(std::uintptr_t other) const;
    [[nodiscard]] basic_address operator+(const basic_address& other) const;
    
    basic_address& operator+=(std::uintptr_t other);
    basic_address& operator+=(const basic_address& other);

    [[nodiscard]] inline bool operator==(const basic_address& other) const;
    [[nodiscard]] inline bool operator==(std::uintptr_t other) const;
    
    [[nodiscard]] inline std::uintptr_t operator*() const;

    basic_address(std::nullptr_t) requires(type == address_type::static_t) = delete;
    basic_address& operator=(std::nullptr_t) requires(type == address_type::static_t) = delete;

    basic_address(std::uintptr_t pointer)
        : pointer(pointer) {}
}; // class basic_address

template<typename T, version_container_option option = version_container_option::add_base>
class versioned_address_container {
public:
    using item_t = basic_address<T>;
private:
    static constexpr std::size_t container_size = std::to_underlying(samp::version::count) - 2;
    
    bool added_base = false;
    std::array<item_t, container_size> container;
public:
    [[nodiscard]] item_t& operator*();
    [[nodiscard]] item_t* operator->();

    template<typename... Args> requires(sizeof...(Args) == container_size)
    versioned_address_container(Args&&... args) : container({ std::forward<Args>(args)... }) {}
}; // class versioned_address_container

template<typename T>
using address = basic_address<T, address_type::static_t>;

template<typename T>
using dynamic_address = basic_address<T, address_type::dynamic>;

template<typename T>
using offset = basic_address<T, address_type::offset>;

} // namespace plugin::types

template<typename T, plugin::types::address_type type>
inline std::uintptr_t
plugin::types::basic_address<T, type>::get() const {
    return pointer;
}

template<typename T, plugin::types::address_type type>
inline bool
plugin::types::basic_address<T, type>::is_available() const {
    return pointer != 0;
}

template<typename T, plugin::types::address_type type>
inline
plugin::types::basic_address<T, type>::operator bool() const {
    return is_available();
}

template<typename T, plugin::types::address_type type>
inline T
plugin::types::basic_address<T, type>::read(std::uintptr_t offset) const {
    if constexpr (std::is_constructible_v<T, basic_address<std::uintptr_t, address_type::dynamic>>)
        return T(*reinterpret_cast<std::uintptr_t*>(pointer + offset));
    else if constexpr (std::is_pointer_v<T>)
        return reinterpret_cast<T>(pointer + offset);
    else
        return *reinterpret_cast<T*>(pointer + offset);
}

template<typename T, plugin::types::address_type type>
inline void
plugin::types::basic_address<T, type>::write(auto value, std::uintptr_t offset) const {
    *reinterpret_cast<T*>(pointer + offset) = value;
}

template<typename T, plugin::types::address_type type>
plugin::types::basic_address<T, type>
plugin::types::basic_address<T, type>::operator+(std::uintptr_t other) const {
    return basic_address(pointer + other);
} 

template<typename T, plugin::types::address_type type>
plugin::types::basic_address<T, type>
plugin::types::basic_address<T, type>::operator+(const basic_address& other) const {
    return basic_address(pointer + *other);
}

template<typename T, plugin::types::address_type type>
plugin::types::basic_address<T, type>&
plugin::types::basic_address<T, type>::operator+=(std::uintptr_t other) {
    pointer += other;
    return *this;
} 

template<typename T, plugin::types::address_type type>
plugin::types::basic_address<T, type>&
plugin::types::basic_address<T, type>::operator+=(const basic_address& other) {
    pointer += *other;
    return *this;
}

template<typename T, plugin::types::address_type type>
inline bool
plugin::types::basic_address<T, type>::operator==(const basic_address& other) const {
    return *this == *other;
} 

template<typename T, plugin::types::address_type type>
inline bool
plugin::types::basic_address<T, type>::operator==(std::uintptr_t other) const {
    return *this == other;
}

template<typename T, plugin::types::address_type type>
inline std::uintptr_t
plugin::types::basic_address<T, type>::operator*() const {
    return get();
}

template<typename T, plugin::types::version_container_option option>
typename plugin::types::versioned_address_container<T, option>::item_t&
plugin::types::versioned_address_container<T, option>::operator*() {
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
typename plugin::types::versioned_address_container<T, option>::item_t*
plugin::types::versioned_address_container<T, option>::operator->() {
    return &this->operator*();
}

#endif // GADMIN_PLUGIN_TYPES_ADDRESS_H
