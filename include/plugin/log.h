#ifndef GADMIN_PLUGIN_LOG_H
#define GADMIN_PLUGIN_LOG_H

#include "plugin/types/simple.h"
#include <functional>
#include <string_view>
#include <format>
#include <utility>

namespace plugin {

class log final {
public:
    enum class type { info, warn, error, fatal };
    using handler_t = std::function<void(const type&, const std::string_view&)>;
private:
    static inline handler_t handler = [](const type&, const std::string_view&) {};
    static constexpr types::zstring_t types[] = { "INFO", "WARN", "ERROR", "FATAL" };

    static auto get_current_time() noexcept -> std::string;

    template<type message_type>
    static auto write(const std::string_view& text) noexcept -> void;
public:
    static auto set_handler(handler_t new_handler) noexcept -> void;

    template<typename... Args>
    static auto info(std::format_string<Args...> fmt, Args&&... args) noexcept -> void;
    
    template<typename... Args>
    static auto warn(std::format_string<Args...> fmt, Args&&... args) noexcept -> void;
    
    template<typename... Args>
    static auto error(std::format_string<Args...> fmt, Args&&... args) noexcept -> void;
    
    template<typename... Args>
    static auto fatal(std::format_string<Args...> fmt, Args&&... args) noexcept -> void;
}; // class log final

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
