#include "plugin/common_utils.h"
#include <chrono>

auto plugin::common_utils::get_current_timestamp() noexcept -> std::string {
    auto now_time_t = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    std::tm tm = *std::localtime(&now_time_t);
    return std::format("[{:02}:{:02}:{:02}]", tm.tm_hour, tm.tm_min, tm.tm_sec);
}
