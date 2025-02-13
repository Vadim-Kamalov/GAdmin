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

inline std::uintptr_t get_base() noexcept;
inline version get_version() noexcept;

inline std::uintptr_t base(std::uintptr_t offset) noexcept;
inline std::uintptr_t base(const std::uintptr_t offsets[std::to_underlying(version::count)]) noexcept;

} // namespace plugin::samp

inline std::uintptr_t
plugin::samp::get_base() noexcept {
    static std::uintptr_t samp_base = std::to_underlying(version::not_loaded);

    if (samp_base == std::to_underlying(version::not_loaded))
        samp_base = reinterpret_cast<std::uintptr_t>(GetModuleHandleA("samp.dll"));

    return samp_base;
}

inline plugin::samp::version
plugin::samp::get_version() noexcept {
    static version version = version::not_loaded;

    if (version <= version::unknown) {
        std::uintptr_t base = get_base();
        
        if (base == std::to_underlying(version::not_loaded))
            return version::not_loaded;

        auto* nt_header = reinterpret_cast<IMAGE_NT_HEADERS*>(base + reinterpret_cast<IMAGE_DOS_HEADER*>(base)->e_lfanew);
        
        switch (nt_header->OptionalHeader.AddressOfEntryPoint) {
            case 0x31DF13:
                version = version::v037R1;
                break;
            case 0xCC4D0:
                version = version::v037R31;
                break;
            case 0xCBC90:
                version = version::v037R51;
                break;
            case 0xFDB60:
                version = version::v03DL1;
                break;
            default:
                version = version::unknown;
                break;
        }
    }

    return version;
}

inline std::uintptr_t
plugin::samp::base(std::uintptr_t offset) noexcept {
    return get_base() + offset;
}

inline std::uintptr_t
plugin::samp::base(const std::uintptr_t offsets[std::to_underlying(version::count)]) noexcept {
    return get_base() + offsets[std::to_underlying(get_version())];
}

template<>
struct std::formatter<plugin::samp::version> : std::formatter<std::string_view> {
    auto format(const plugin::samp::version& version, std::format_context& ctx) const {
        static constexpr plugin::types::zstring_t versions[] = { "not loaded", "unknown", "v0.3.7-R1", "v0.3.7-R3-1", "v0.3.7-R5-1", "v0.3-DL-1" };
        return std::formatter<std::string_view>::format(versions[std::to_underlying(version)], ctx);
    }
}; // struct std::formatter<plugin::samp::version> : std::formatter<std::string_view>

#endif // GADMIN_PLUGIN_SAMP_SAMP_H
