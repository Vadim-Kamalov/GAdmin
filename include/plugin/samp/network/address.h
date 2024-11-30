#ifndef GADMIN_PLUGIN_SAMP_NETWORK_ADDRESS_H
#define GADMIN_PLUGIN_SAMP_NETWORK_ADDRESS_H

#include "plugin/samp/samp.h"

namespace plugin::samp::address {

    // ENTRY(CNetGame,                 0x0, 0x0, 0x21A0F8, 0x26E8DC, 0x26EB94, 0x2ACA24
    // ENTRY(StringWriteEncoder,       0x0, 0x0, 0x506B0, 0x53A60, 0x541A0, 0x53C60
    // ENTRY(StringReadDecoder,        0x0, 0x0, 0x507E0, 0x53B90, 0x542D0, 0x53D90
    // ENTRY(CompressorPtr,            0x0, 0x0, 0x10D894, 0x121914, 0x121A3C, 0x15FA54
    // ENTRY(HandleRpc,                0x0, 0x0, 0x372F0, 0x3A6A0, 0x3ADE0, 0x3A8A0
    // ENTRY(RakClientIntfConstr,      0x0, 0x0, 0x33DC0, 0x37170, 0x378B0, 0x37370
    // ENTRY(alloc_packet,             0x0, 0x0, 0x347E0, 0x37B90, 0x382D0, 0x37D90
    // ENTRY(write_lock,               0x0, 0x0, 0x35B10, 0x38EC0, 0x39600, 0x390C0
    // ENTRY(write_unlock,             0x0, 0x0, 0x35B50, 0x38F00, 0x39640, 0x39100

constexpr std::uintptr_t
rak_client_interface_constructor(const Version& version = get_version()) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x33DC0, 0x37170, 0x378B0, 0x37370 };
    return base(offsets[std::to_underlying(version)]);
}

constexpr std::uintptr_t
incoming_rpc_handler(const Version& version = get_version()) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x372F0, 0x3A6A0, 0x3ADE0, 0x3A8A0 };
    return base(offsets[std::to_underlying(version)]);
}

constexpr std::uintptr_t
encoded_reader(const Version& version = get_version()) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x507E0, 0x53B90, 0x542D0, 0x53D90 };
    return base(offsets[std::to_underlying(version)]);
}

constexpr std::uintptr_t
encoded_writer(const Version& version = get_version()) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x506B0, 0x53A60, 0x541A0, 0x53C60 };
    return base(offsets[std::to_underlying(version)]);
}

constexpr std::uintptr_t
encode_decode_base(const Version& version = get_version()) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x10D894, 0x121914, 0x121A3C, 0x15FA54 };
    return *reinterpret_cast<std::uintptr_t*>(base(offsets[std::to_underlying(version)]));
}

constexpr std::uintptr_t
allocate_packet(const Version& version = get_version()) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x347E0, 0x37B90, 0x382D0, 0x37D90 };
    return base(offsets[std::to_underlying(version)]);
}

constexpr std::uintptr_t
write_lock(const Version& version = get_version()) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x35B10, 0x38EC0, 0x39600, 0x390C0 };
    return base(offsets[std::to_underlying(version)]);
}

constexpr std::uintptr_t
write_unlock(const Version& version = get_version()) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x35B50, 0x38F00, 0x39640, 0x39100 };
    return base(offsets[std::to_underlying(version)]);
}

} // namespace plugin::samp::address

#endif // GADMIN_PLUGIN_SAMP_NETWORK_ADDRESS_H
