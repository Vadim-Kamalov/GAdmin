#ifndef GADMIN_PLUGIN_SAMP_NETWORK_BIT_STREAM_H
#define GADMIN_PLUGIN_SAMP_NETWORK_BIT_STREAM_H

#include "raknet/bit_stream.h"
#include "raknet/rak_client.h"
#include <string>
#include <cstdint>

namespace plugin::samp {

class BitStream {
private:
    ::BitStream* bit_stream;
    bool delete_bit_stream = true;
public:
    int get_number_of_bits_used();
    int get_number_of_bytes_used();

    int get_number_of_unread_bits();
    int get_number_of_unread_bytes();

    void reset_read_pointer();
    void reset_write_pointer();
    void reset_bit_stream();

    int get_read_offset();
    int get_write_offset();

    void set_read_offset(int offset);
    void set_write_offset(int offset);

    void ignore_bits(int count);
    void ignore_bytes(int count);

    template<typename T>
    T read() {
        T result;
        bit_stream->Read(result);
        return result;
    }
    
    template<typename T>
    void write(T value) { bit_stream->Write(value); }

    template<typename T>
    std::string read_string() { return read_string(read<T>()); }

    std::string read_string(std::int32_t length);
    std::string read_encoded(int length);
    bool read_buffer(std::uintptr_t destination, int size);

    void write(const std::string_view& value);
    void write_encoded(const std::string_view& value);

    bool emulate_incoming_rpc(std::uint8_t rpc_id);
    bool emulate_incoming_packet(std::uint8_t packet_id);

    bool send_rpc(int rpc_id);
    bool send_rpc(int rpc_id, PacketPriority priority, PacketReliability reliability, std::uint8_t channel, bool timestamp);
    bool send_packet();
    bool send_packet(PacketPriority priority, PacketReliability reliability, std::uint8_t channel);

    ::BitStream* get_original_bit_stream();
    std::uintptr_t get_data_ptr();

    explicit BitStream()
        : bit_stream(new ::BitStream) {}

    explicit BitStream(::BitStream* bit_stream)
        : bit_stream(bit_stream), delete_bit_stream(false) {}

    BitStream(unsigned char* data, unsigned int length, bool copy_data)
        : bit_stream(new ::BitStream(data, BITS_TO_BYTES(length), copy_data)) {}

    ~BitStream();
}; // class BitStream

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_NETWORK_BIT_STREAM_H
