#ifndef GADMIN_PLUGIN_LOG_H
#define GADMIN_PLUGIN_LOG_H

#include <functional>
#include <string_view>
#include <optional>
#include <format>
#include <chrono>
#include <windows.h>

namespace plugin::log {

inline std::optional<std::function<void(std::string_view)>> handler;

static std::string
get_current_time() noexcept {
    auto now = std::chrono::system_clock::now();
    auto now_time_t = std::chrono::system_clock::to_time_t(now);
    auto now_tm = *std::localtime(&now_time_t);

    std::tm gmt_tm = *std::gmtime(&now_time_t);
    auto local_time = std::mktime(const_cast<std::tm*>(&now_tm));
    auto gmt_time = std::mktime(const_cast<std::tm*>(&gmt_tm));
    auto timezone_offset = std::difftime(local_time, gmt_time);
    int hours_offset = static_cast<int>(timezone_offset / 3600);
    int minutes_offset = static_cast<int>(static_cast<int>(timezone_offset / 60) % 60);

    auto duration = now.time_since_epoch();
    auto seconds = std::chrono::duration_cast<std::chrono::seconds>(duration);
    auto nanoseconds = std::chrono::duration_cast<std::chrono::nanoseconds>(duration - seconds);

    std::ostringstream oss;
    oss << std::put_time(&now_tm, "%Y-%m-%dT%H:%M:%S")
        << '.' << std::setfill('0') << std::setw(9) << nanoseconds.count()
        << (hours_offset >= 0 ? '+' : '-')
        << std::setfill('0') << std::setw(2) << std::abs(hours_offset)
        << ':' << std::setfill('0') << std::setw(2) << std::abs(minutes_offset);

    return oss.str();
}

inline void
set_handler(const std::function<void(std::string_view)>& new_handler) noexcept {
    handler = new_handler;
}

static void
write(const std::string_view& tag, const std::string_view& text) noexcept {
    if (!handler.has_value())
        return;

    (*handler)(std::format("{} [{}] {}", get_current_time(), tag, text));
}

template<typename... Args>
static inline void
info(std::format_string<Args...> fmt, Args&&... args) noexcept {
    write("INFO", std::format(fmt, std::forward<Args>(args)...));
}

template<typename... Args>
static inline void
warn(std::format_string<Args...> fmt, Args&&... args) noexcept {
    write("WARN", std::format(fmt, std::forward<Args>(args)...));
}

template<typename... Args>
static inline void
error(std::format_string<Args...> fmt, Args&&... args) noexcept {
    write("ERROR", std::format(fmt, std::forward<Args>(args)...));
}

template<typename... Args>
static inline void
fatal(std::format_string<Args...> fmt, Args&&... args) noexcept {
    write("FATAL", std::format(fmt, std::forward<Args>(args)...));
}

} // namespace plugin::log

#endif // GADMIN_PLUGIN_LOG_H
