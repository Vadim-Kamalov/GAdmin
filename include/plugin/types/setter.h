#ifndef GADMIN_PLUGIN_TYPES_SETTER_H
#define GADMIN_PLUGIN_TYPES_SETTER_H

#include <concepts>
#include <memory>
#include <variant>

namespace plugin::types {

template<typename T>
class setter_proxy {
public:
    constexpr virtual ~setter_proxy() = default;
    constexpr virtual auto operator*() const -> T = 0;
    constexpr virtual auto operator=(const T& value) -> void = 0;
}; // class setter_proxy

template<typename T>
using setter_proxy_ptr_t = std::shared_ptr<setter_proxy<T>>; // FIXME: std::shared_ptr is bad here. use std::unique_ptr

template<typename T>
class setter final {
public:
    using proxy_t = setter_proxy_ptr_t<T>;
private:
    std::variant<T*, proxy_t> value;
public:
    auto reset(const T& new_value) -> void;
    auto get() const -> T;

    template<std::derived_from<setter_proxy<T>> derived_proxy>
    static auto from_proxy(const derived_proxy& proxy) noexcept -> setter {
        return setter(std::make_shared<derived_proxy>(proxy));
    }

    auto operator=(const T& new_value) -> void;
    explicit operator bool() const requires(std::is_same_v<T, bool>);
    auto operator*() const -> T;

    explicit setter(const proxy_t& proxy) : value(std::move(proxy)) {}
    explicit setter(T& value) : value(std::addressof(value)) {}
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
