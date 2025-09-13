#include "plugin/log.h"
#include <chrono>

auto plugin::log::get_current_time() noexcept -> std::string {
    auto now = std::chrono::system_clock::now();
    std::time_t now_time_t = std::chrono::system_clock::to_time_t(now);

    std::tm now_tm = *std::localtime(&now_time_t);
    std::tm gmt_tm = *std::gmtime(&now_time_t);

    std::time_t local_time = std::mktime(&now_tm);
    std::time_t gmt_time = std::mktime(&gmt_tm);

    int timezone_offset = std::difftime(local_time, gmt_time);
    int hours_offset = timezone_offset / 3600;
    int minutes_offset = (timezone_offset / 60) % 60;

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

auto plugin::log::set_handler(handler_t new_handler) noexcept -> void {
    handler = new_handler;
}
