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
    constexpr virtual T operator()() const = 0;
    constexpr virtual void operator=(const T& value) = 0;
}; // class setter_proxy

template<typename T>
using setter_proxy_ptr_t = std::shared_ptr<setter_proxy<T>>;

template<typename T>
class setter {
public:
    using proxy_t = setter_proxy_ptr_t<T>;
private:
    std::variant<T*, proxy_t> value;
public:
    void reset(const T& new_value);
    T get() const;

    template<std::derived_from<setter_proxy<T>> derived_proxy>
    static setter from_proxy(const derived_proxy& proxy) noexcept {
        return setter(std::make_shared<derived_proxy>(proxy));
    }

    void operator=(const T& new_value);
    explicit operator bool() const requires(std::is_same_v<T, bool>);
    T operator()() const;

    explicit setter(const proxy_t& proxy) : value(std::move(proxy)) {}
    explicit setter(T& value) : value(std::addressof(value)) {}
}; // class setter

} // namespace plugin::types

template<typename T>
void
plugin::types::setter<T>::reset(const T& new_value) {
    if (std::holds_alternative<T*>(value)) {
        *std::get<T*>(value) = new_value;
        return;
    }

    (*std::get<proxy_t>(value)) = new_value;
}

template<typename T>
T
plugin::types::setter<T>::get() const {
    if (std::holds_alternative<T*>(value))
        return *std::get<T*>(value);

    return (*std::get<proxy_t>(value))();
}

template<typename T>
T
plugin::types::setter<T>::operator()() const {
    return get();
}

template<typename T>
void
plugin::types::setter<T>::operator=(const T& new_value) {
    reset(new_value);
}

template<typename T>
plugin::types::setter<T>::operator bool() const requires(std::is_same_v<T, bool>) {
    return get();
}

#endif // GADMIN_PLUGIN_TYPES_SETTER_H
