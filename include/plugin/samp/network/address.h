#ifndef GADMIN_PLUGIN_SAMP_NETWORK_ADDRESS_H
#define GADMIN_PLUGIN_SAMP_NETWORK_ADDRESS_H

#include <cstdint>

namespace plugin::samp::address {

std::uintptr_t rak_client_interface_constructor() noexcept;
std::uintptr_t incoming_rpc_handler() noexcept;
std::uintptr_t encoded_reader() noexcept;
std::uintptr_t encoded_writer() noexcept;
std::uintptr_t encode_decode_base() noexcept;
std::uintptr_t allocate_packet() noexcept;
std::uintptr_t write_lock() noexcept;
std::uintptr_t write_unlock() noexcept;

} // namespace plugin::samp::address

#endif // GADMIN_PLUGIN_SAMP_NETWORK_ADDRESS_H
