#include "plugin/log.h"
#include <chrono>

std::string
plugin::log::get_current_time() noexcept {
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

void
plugin::log::set_handler(handler_t new_handler) noexcept {
    handler = new_handler;
}
