#ifndef GADMIN_PLUGIN_SAMP_SAMP_H
#define GADMIN_PLUGIN_SAMP_SAMP_H

#include <cstdint>
#include <utility>
#include <format>
#include <windows.h>
#include "plugin/types/simple.h"

namespace plugin::samp {

enum class version {
    not_loaded,
    unknown,
    v037R1,
    v037R31,
    v037R51,
    v03DL1,
    count
}; // enum class version

auto get_base() noexcept -> std::uintptr_t;
auto get_version() noexcept -> version;

inline auto base(std::uintptr_t offset) noexcept -> std::uintptr_t;
inline auto base(const std::uintptr_t offsets[std::to_underlying(version::count)]) noexcept -> std::uintptr_t;

} // namespace plugin::samp

inline auto plugin::samp::base(std::uintptr_t offset) noexcept -> std::uintptr_t {
    return get_base() + offset;
}

inline auto plugin::samp::base(const std::uintptr_t offsets[std::to_underlying(version::count)]) noexcept -> std::uintptr_t {
    return get_base() + offsets[std::to_underlying(get_version())];
}

template<>
struct std::formatter<plugin::samp::version> : std::formatter<std::string_view> {
    auto format(const plugin::samp::version& version, std::format_context& ctx) const {
        static constexpr plugin::types::zstring_t versions[] = { "not loaded", "unknown", "v0.3.7-R1",
                                                                 "v0.3.7-R3-1", "v0.3.7-R5-1", "v0.3-DL-1" };

        return std::formatter<std::string_view>::format(versions[std::to_underlying(version)], ctx);
    }
}; // struct std::formatter<plugin::samp::version> : std::formatter<std::string_view>

#endif // GADMIN_PLUGIN_SAMP_SAMP_H
