#ifndef GADMIN_PLUGIN_SAMP_NETWORK_ADDRESS_H
#define GADMIN_PLUGIN_SAMP_NETWORK_ADDRESS_H

#include <cstdint>

namespace plugin::samp::address {

auto rak_client_interface_constructor() noexcept -> std::uintptr_t;
auto incoming_rpc_handler() noexcept -> std::uintptr_t;
auto encoded_reader() noexcept -> std::uintptr_t;
auto encoded_writer() noexcept -> std::uintptr_t;
auto encode_decode_base() noexcept -> std::uintptr_t;
auto allocate_packet() noexcept -> std::uintptr_t;
auto write_lock() noexcept -> std::uintptr_t;
auto write_unlock() noexcept -> std::uintptr_t;

} // namespace plugin::samp::address

#endif // GADMIN_PLUGIN_SAMP_NETWORK_ADDRESS_H
