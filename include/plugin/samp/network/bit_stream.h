/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_SAMP_NETWORK_BIT_STREAM_H
#define GADMIN_PLUGIN_SAMP_NETWORK_BIT_STREAM_H

#include "raknet/bit_stream.h"
#include "raknet/rak_client.h"
#include "plugin/types/simple.h"
#include "plugin/types/address.h"
#include <string>
#include <cstdint>

namespace plugin {
namespace signatures {

using encoded_reader_t = bool(__thiscall*)(std::uintptr_t, char*, int, BitStream*, int);
using encoded_writer_t = void(__thiscall*)(std::uintptr_t, types::zstring_t, int, BitStream*, int);
using allocate_packet_t = Packet*(*)(int);
using write_lock_t = Packet**(__thiscall*)(void*);
using write_unlock_t = void(__thiscall*)(void*);
using send_rpc_t = bool(__thiscall*)(std::uintptr_t, int*, BitStream*, PacketPriority, PacketReliability, char, bool);
using send_packet_t = bool(__thiscall*)(std::uintptr_t, BitStream*, PacketPriority, PacketReliability, char);

} // namespace signatures

namespace samp {

/// Represents a wrapper for the RakNet BitStream class with features related
/// to the SA:MP client, such as sending or emulating RPCs/packets.
class bit_stream final {
private:
    BitStream* bit_stream_ptr = nullptr;
    bool delete_bit_stream = true;

    static types::versioned_address_container<signatures::encoded_reader_t> encoded_reader_container;
    static types::versioned_address_container<signatures::encoded_writer_t> encoded_writer_container;
    static types::versioned_address_container<signatures::allocate_packet_t> allocate_packet_container;
    static types::versioned_address_container<signatures::write_lock_t> write_lock_container;
    static types::versioned_address_container<signatures::write_unlock_t> write_unlock_container;
    static types::versioned_address_container<std::uintptr_t> encode_decode_base_container;
public:
    /// Get length in bits of the stream.
    ///
    /// @return Length in bits of the stream
    auto get_number_of_bits_used() -> int;

    /// Get length in bytes of the stream.
    ///
    /// @return Length in bytes of the stream
    auto get_number_of_bytes_used() -> int;

    /// Get number of bits left in the stream that haven't been read.
    ///
    /// @return Number of bits left in the stream that haven't been read.
    auto get_number_of_unread_bits() -> int;

    /// Get number of bytes left in the stream that haven't been read.
    ///
    /// @return Number of bytes left in the stream that haven't been read.
    auto get_number_of_unread_bytes() -> int;

    /// Set the read pointer back to the beginning of stream's data.
    auto reset_read_pointer() -> void;

    /// Set the write pointer back to the beginning of stream's data.
    auto reset_write_pointer() -> void;

    /// Reset the stream for reuse.
    auto reset_bit_stream() -> void;

    /// Get the number of bits into the stream that we have read.
    /// 
    /// @return Number of bits into the stream that we have read.
    auto get_read_offset() -> int;
    
    /// Get the number of bits into the stream that we have wrote.
    /// 
    /// @return Number of bits into the stream that we have wrote.
    auto get_write_offset() -> int;

    /// Set the read bit index.
    ///
    /// @param offset[int] New read bit index.
    auto set_read_offset(int offset) -> void;
    
    /// Set the write bit index.
    ///
    /// @param offset[int] New write bit index.
    auto set_write_offset(int offset) -> void;

    /// Ignore data in bits we don't intend to read.
    ///
    /// @param count[in] Number of bits to ignore.
    auto ignore_bits(int count) -> void;
    
    /// Ignore data in bytes we don't intend to read.
    ///
    /// @param count[in] Number of bytes to ignore.
    auto ignore_bytes(int count) -> void;

    /// Read value from the stream.
    ///
    /// @tparam T Return value type.
    /// @return   Value from the stream.
    template<typename T>
    auto read() -> T;
    
    /// Write value in the stream.
    ///
    /// @tparam T        Write value type.
    /// @param value[in] Value to write.
    template<typename T>
    auto write(T value) -> void;

    /// Read string from the stream with fixed size.
    ///
    /// @tparam T Size type for the string length.
    /// @return   String from the stream.
    template<typename T>
    auto read_string() -> std::string;

    /// Write string into the stream with fixed size.
    ///
    /// @tparam T      Size type for the string length.
    /// @param str[in] String to write.
    template<typename T>
    auto write_string(const std::string_view& str) -> void;

    /// Read multiple values from the stream into the provided variables.
    ///
    /// @note           Order of the arguments must match the order of the values in the stream.
    /// @tparam Args    Types of the arguments to read.
    /// @param args[in] References to the variables where the read values will be stored.
    template<typename... Args>
    auto read_into(Args&... args) -> void;

    /// Read a string of a specified length from the stream.
    ///
    /// @param length[in] Length of the string to read (in bytes).
    /// @return           String read from the stream.
    auto read_string(std::int32_t length) -> std::string;

    /// Read an encoded string of a specified length from the stream.
    ///
    /// @note             Uses the SA:MP encoding/decoding logic for strings.
    /// @param length[in] Length of the encoded string to read (in bytes).
    /// @return           Decoded string.
    auto read_encoded(int length) -> std::string;

    /// Read a buffer of data from the stream into a specified memory location.
    ///
    /// @param destination[in] Memory address where the data will be written.
    /// @param size[in]        Size of the buffer to read (in bytes).
    /// @return                True if the read was successful.
    auto read_buffer(std::uintptr_t destination, int size) -> bool;

    /// Write a string into the stream.
    ///
    /// @param value[in] String to write.
    auto write(const std::string_view& value) -> void;

    /// Write an encoded string into the stream.
    ///
    /// @note            Uses the SA:MP encoding/decoding logic for strings.
    /// @param value[in] String to encode and write.
    auto write_encoded(const std::string_view& value) -> void;

    /// Emulate an incoming RPC with the specified RPC ID.
    ///
    /// @param rpc_id[in] ID of the RPC to emulate.
    /// @return           True if the emulation was successful.
    auto emulate_incoming_rpc(std::uint8_t rpc_id) -> bool;

    /// Emulate an incoming packet with the specified packet ID.
    ///
    /// @param packet_id[in] ID of the packet to emulate.
    /// @return              True if the emulation was successful.
    auto emulate_incoming_packet(std::uint8_t packet_id) -> bool;

    /// Send an RPC with the specified RPC ID.
    ///
    /// @note             Uses the default priority, reliability, and channel settings.
    /// @param rpc_id[in] ID of the RPC to send.
    /// @return           True if the RPC was sent successfully.
    auto send_rpc(int rpc_id) -> bool;

    /// Sends an RPC with custom priority, reliability, and channel settings.
    ///
    /// @param rpc_id[in]      ID of the RPC to send.
    /// @param priority[in]    Priority of the RPC (e.g., `PacketPriority::HIGH`).
    /// @param reliability[in] Reliability of the RPC (e.g., `PacketReliability::RELIABLE`).
    /// @param channel[in]     Channel to use for sending the RPC.
    /// @param timestamp[in]   Whether to include a timestamp in the RPC.
    /// @return                True if the RPC was sent successfully.
    auto send_rpc(int rpc_id, PacketPriority priority, PacketReliability reliability, std::uint8_t channel, bool timestamp) -> bool;

    /// Send the current packet in the stream.
    ///
    /// @note   Uses the default priority, reliability, and channel settings.
    /// @return True if the packet was sent successfully.
    auto send_packet() -> bool;

    /// Send the current packet in the stream with custom priority, reliability, and channel settings.
    ///
    /// @param priority[in]    Priority of the packet (e.g., `PacketPriority::HIGH`).
    /// @param reliability[in] Reliability of the packet (e.g., `PacketReliability::RELIABLE`).
    /// @param channel[in]     Channel to use for sending the packet.
    /// @return                True if the packet was sent successfully.
    auto send_packet(PacketPriority priority, PacketReliability reliability, std::uint8_t channel) -> bool;

    /// Get the original RakNet `BitStream` object.
    ///
    /// @return Pointer to the original `BitStream` object.
    auto get_original_bit_stream() -> BitStream*;

    /// Get a pointer to the underlying data buffer of the stream.
    ///
    /// @return Pointer to the data buffer.
    auto get_data_ptr() -> std::uintptr_t;

    /// Default constructor. Initializes a new `BitStream` object.
    explicit bit_stream()
        : bit_stream(new BitStream) {}

    /// Construct and wrap an existing `BitStream` object.
    ///
    /// @param bit_stream[in] Pointer to an existing `BitStream` object.
    /// @note                 Pointer object will not be released by this class.
    explicit bit_stream(BitStream* bit_stream)
        : bit_stream_ptr(bit_stream), delete_bit_stream(false) {}

    /// Construct the stream with external data.
    ///
    /// @param data[in]      Pointer to the data buffer.
    /// @param length[in]    Length of the data buffer (in bits).
    /// @param copy_data[in] Whether to copy the data buffer.
    bit_stream(unsigned char* data, unsigned int length, bool copy_data)
        : bit_stream(new BitStream(data, BITS_TO_BYTES(length), copy_data)) {}

    /// Destructor for the `bit_stream` class. Releases the internal
    /// `BitStream` object if `delete_bit_stream` is `true`.
    ~bit_stream() noexcept;
}; // class bit_stream final

} // namespace samp
} // namespace plugin

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
