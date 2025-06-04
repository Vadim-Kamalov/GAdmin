#ifndef GADMIN_PLUGIN_SAMP_NETWORK_BIT_STREAM_H
#define GADMIN_PLUGIN_SAMP_NETWORK_BIT_STREAM_H

#include "raknet/bit_stream.h"
#include "raknet/rak_client.h"
#include <string>
#include <cstdint>

namespace plugin::samp {

class bit_stream final {
private:
    BitStream* bit_stream_ptr;
    bool delete_bit_stream = true;
public:
    auto get_number_of_bits_used() -> int;
    auto get_number_of_bytes_used() -> int;

    auto get_number_of_unread_bits() -> int;
    auto get_number_of_unread_bytes() -> int;

    auto reset_read_pointer() -> void;
    auto reset_write_pointer() -> void;
    auto reset_bit_stream() -> void;

    auto get_read_offset() -> int;
    auto get_write_offset() -> int;

    auto set_read_offset(int offset) -> void;
    auto set_write_offset(int offset) -> void;

    auto ignore_bits(int count) -> void;
    auto ignore_bytes(int count) -> void;

    template<typename T>
    auto read() -> T;
    
    template<typename T>
    auto write(T value) -> void;

    template<typename T>
    auto read_string() -> std::string;

    template<typename T>
    auto write_string(const std::string_view& str) -> void;

    template<typename... Args>
    auto read_into(Args&... args) -> void;

    auto read_string(std::int32_t length) -> std::string;
    auto read_encoded(int length) -> std::string;
    auto read_buffer(std::uintptr_t destination, int size) -> bool;

    auto write(const std::string_view& value) -> void;
    auto write_encoded(const std::string_view& value) -> void;

    auto emulate_incoming_rpc(std::uint8_t rpc_id) -> bool;
    auto emulate_incoming_packet(std::uint8_t packet_id) -> bool;

    auto send_rpc(int rpc_id) -> bool;
    auto send_rpc(int rpc_id, PacketPriority priority, PacketReliability reliability, std::uint8_t channel, bool timestamp) -> bool;
    auto send_packet() -> bool;
    auto send_packet(PacketPriority priority, PacketReliability reliability, std::uint8_t channel) -> bool;

    auto get_original_bit_stream() -> BitStream*;
    auto get_data_ptr() -> std::uintptr_t;

    explicit bit_stream()
        : bit_stream(new BitStream) {}

    explicit bit_stream(BitStream* bit_stream)
        : bit_stream_ptr(bit_stream), delete_bit_stream(false) {}

    bit_stream(unsigned char* data, unsigned int length, bool copy_data)
        : bit_stream(new BitStream(data, BITS_TO_BYTES(length), copy_data)) {}

    ~bit_stream() noexcept;
}; // class bit_stream final

} // namespace plugin::samp

template<typename T>
auto plugin::samp::bit_stream::read() -> T {
    T result;
    bit_stream_ptr->Read(result);
    return result;
}
    
template<typename T>
auto plugin::samp::bit_stream::write(T value) -> void{
    bit_stream_ptr->Write(value);
}

template<typename T>
auto plugin::samp::bit_stream::read_string() -> std::string {
    return read_string(read<T>());
}

template<typename T>
auto plugin::samp::bit_stream::write_string(const std::string_view& str) -> void {
    T size = static_cast<T>(str.size());
    bit_stream_ptr->Write(size);
    bit_stream_ptr->Write(str.data(), size);
}

template<typename... Args>
auto plugin::samp::bit_stream::read_into(Args&... args) -> void {
    ((args = read<std::decay_t<Args>>()), ...);
}

#endif // GADMIN_PLUGIN_SAMP_NETWORK_BIT_STREAM_H
