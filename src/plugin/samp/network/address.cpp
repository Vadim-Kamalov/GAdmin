#include "plugin/samp/network/address.h"
#include "plugin/samp/samp.h"

std::uintptr_t
plugin::samp::address::rak_client_interface_constructor() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x33DC0, 0x37170, 0x378B0, 0x37370 };
    return base(offsets);
}

std::uintptr_t
plugin::samp::address::incoming_rpc_handler() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x372F0, 0x3A6A0, 0x3ADE0, 0x3A8A0 };
    return base(offsets);
}

std::uintptr_t
plugin::samp::address::encoded_reader() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x507E0, 0x53B90, 0x542D0, 0x53D90 };
    return base(offsets);
}

std::uintptr_t
plugin::samp::address::encoded_writer() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x506B0, 0x53A60, 0x541A0, 0x53C60 };
    return base(offsets);
}

std::uintptr_t
plugin::samp::address::encode_decode_base() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x10D894, 0x121914, 0x121A3C, 0x15FA54 };
    return *reinterpret_cast<std::uintptr_t*>(base(offsets));
}

std::uintptr_t
plugin::samp::address::allocate_packet() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x347E0, 0x37B90, 0x382D0, 0x37D90 };
    return base(offsets);
}

std::uintptr_t
plugin::samp::address::write_lock() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x35B10, 0x38EC0, 0x39600, 0x390C0 };
    return base(offsets);
}

std::uintptr_t
plugin::samp::address::write_unlock() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x35B50, 0x38F00, 0x39640, 0x39100 };
    return base(offsets);
}
