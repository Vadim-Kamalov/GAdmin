#include "plugin/samp/samp.h"

auto plugin::samp::get_base() noexcept -> std::uintptr_t {
    static std::uintptr_t samp_base = std::to_underlying(version::not_loaded);

    if (samp_base == std::to_underlying(version::not_loaded))
        samp_base = reinterpret_cast<std::uintptr_t>(GetModuleHandleA("samp.dll"));

    return samp_base;
}

auto plugin::samp::get_version() noexcept -> version {
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
