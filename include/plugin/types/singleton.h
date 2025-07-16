#ifndef GADMIN_PLUGIN_TYPES_SINGLETON_H
#define GADMIN_PLUGIN_TYPES_SINGLETON_H

#include <type_traits>
#include <utility>

namespace plugin::types {

template<typename T>
class singleton {
public:
    virtual ~singleton() = default;

    template<typename... Args> requires std::is_constructible_v<T, Args...>
    static auto instance(Args&&... args) noexcept -> T& {
        static auto instance = T(std::forward<Args>(args)...);
        return instance;
    }
}; // class singleton

} // namespace plugin::types

#endif // GADMIN_PLUGIN_TYPES_SINGLETON_H
