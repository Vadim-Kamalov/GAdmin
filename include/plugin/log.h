#ifndef GADMIN_PLUGIN_LOG_H
#define GADMIN_PLUGIN_LOG_H

#include "plugin/types/simple.h"
#include <functional>
#include <string_view>
#include <format>
#include <utility>

namespace plugin {

class log {
public:
    enum class type { info, warn, error, fatal };
    using handler_t = std::function<void(const type&, const std::string_view&)>;
private:
    static inline handler_t handler = [](const type&, const std::string_view&) {};
    static constexpr types::zstring_t types[] = { "INFO", "WARN", "ERROR", "FATAL" };

    static std::string get_current_time() noexcept;

    template<type message_type>
    static void write(const std::string_view& text) noexcept;
public:
    static void set_handler(handler_t new_handler) noexcept;

    template<typename... Args>
    static void info(std::format_string<Args...> fmt, Args&&... args) noexcept;
    
    template<typename... Args>
    static void warn(std::format_string<Args...> fmt, Args&&... args) noexcept;
    
    template<typename... Args>
    static void error(std::format_string<Args...> fmt, Args&&... args) noexcept;
    
    template<typename... Args>
    static void fatal(std::format_string<Args...> fmt, Args&&... args) noexcept;
}; // class log

} // namespace plugin

template<plugin::log::type message_type>
void
plugin::log::write(const std::string_view& text) noexcept {
    handler(message_type, std::format("{} [{}] {}", get_current_time(),
                                      types[std::to_underlying(message_type)], text));
}

template<typename... Args>
void
plugin::log::info(std::format_string<Args...> fmt, Args&&... args) noexcept {
    write<type::info>(std::format(fmt, std::forward<Args>(args)...));
}

template<typename... Args>
void
plugin::log::warn(std::format_string<Args...> fmt, Args&&... args) noexcept {
    write<type::warn>(std::format(fmt, std::forward<Args>(args)...));
}

template<typename... Args>
void
plugin::log::error(std::format_string<Args...> fmt, Args&&... args) noexcept {
    write<type::error>(std::format(fmt, std::forward<Args>(args)...));
}

template<typename... Args>
void
plugin::log::fatal(std::format_string<Args...> fmt, Args&&... args) noexcept {
    write<type::fatal>(std::format(fmt, std::forward<Args>(args)...));
}

#endif // GADMIN_PLUGIN_LOG_H
