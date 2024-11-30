#ifndef GADMIN_PLUGIN_SAMP_SAMP_H
#define GADMIN_PLUGIN_SAMP_SAMP_H

#include <cstdint>
#include <utility>
#include <windows.h>

namespace plugin::samp {

enum class Version {
    NotLoaded,
    Unknown,
    V037R1,
    V037R31,
    V037R51,
    V037DL1
}; // enum class Version

inline std::uintptr_t
get_base() noexcept {
    static std::uintptr_t samp_base = std::to_underlying(Version::NotLoaded);

    if (samp_base == std::to_underlying(Version::NotLoaded))
        samp_base = reinterpret_cast<std::uintptr_t>(GetModuleHandleA("samp.dll"));

    return samp_base;
}

inline std::uintptr_t
base(std::uintptr_t offset) noexcept {
    return get_base() + offset;
}

inline Version
get_version() noexcept {
    static Version version = Version::NotLoaded;

    if (version <= Version::Unknown) {
        std::uintptr_t base = get_base();
        
        if (base == std::to_underlying(Version::NotLoaded))
            return Version::NotLoaded;

        auto* nt_header = reinterpret_cast<IMAGE_NT_HEADERS*>(base + reinterpret_cast<IMAGE_DOS_HEADER*>(base)->e_lfanew);
        
        switch (nt_header->OptionalHeader.AddressOfEntryPoint) {
            case 0x31DF13:
                version = Version::V037R1;
                break;
            case 0xCC4D0:
                version = Version::V037R31;
                break;
            case 0xCBC90:
                version = Version::V037R51;
                break;
            default:
                version = Version::Unknown;
                break;
        }
    }

    return version;
}

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_SAMP_H
