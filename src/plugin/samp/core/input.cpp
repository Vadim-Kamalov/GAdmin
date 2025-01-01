#include "plugin/samp/core/input.h"

std::uintptr_t
plugin::samp::input::instance() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x21A0E8, 0x26E8CC, 0x26EB84, 0x2ACA14 };
    return *reinterpret_cast<std::uintptr_t*>(base(offsets));
}

bool
plugin::samp::input::is_active() noexcept {
    return *reinterpret_cast<int*>(instance() + 0x14E0) != 0;
}
