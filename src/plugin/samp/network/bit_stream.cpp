/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2026 The Contributors.
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

#include "plugin/samp/network/bit_stream.h"
#include "plugin/plugin.h"

plugin::types::versioned_address_container<plugin::signatures::encoded_reader_t>
plugin::samp::bit_stream::encoded_reader_container = { 0x507E0, 0x53B90, 0x542D0, 0x53D90 };

plugin::types::versioned_address_container<plugin::signatures::encoded_writer_t>
plugin::samp::bit_stream::encoded_writer_container = { 0x506B0, 0x53A60, 0x541A0, 0x53C60 };

plugin::types::versioned_address_container<plugin::signatures::allocate_packet_t>
plugin::samp::bit_stream::allocate_packet_container = { 0x347E0, 0x37B90, 0x382D0, 0x37D90 };

plugin::types::versioned_address_container<plugin::signatures::write_lock_t>
plugin::samp::bit_stream::write_lock_container = { 0x35B10, 0x38EC0, 0x39600, 0x390C0 };

plugin::types::versioned_address_container<plugin::signatures::write_unlock_t>
plugin::samp::bit_stream::write_unlock_container = { 0x35B50, 0x38F00, 0x39640, 0x39100 };

plugin::types::versioned_address_container<std::uintptr_t>
plugin::samp::bit_stream::encode_decode_base_container = { 0x10D894, 0x121914, 0x121A3C, 0x15FA54 };

auto plugin::samp::bit_stream::get_number_of_bits_used() -> int {
    return bit_stream_ptr->GetNumberOfBitsUsed();
}

auto plugin::samp::bit_stream::get_number_of_bytes_used() -> int {
    return bit_stream_ptr->GetNumberOfBytesUsed();
}

auto plugin::samp::bit_stream::get_number_of_unread_bits() -> int {
    return bit_stream_ptr->GetNumberOfUnreadBits();
}

auto plugin::samp::bit_stream::get_number_of_unread_bytes() -> int {
    return BITS_TO_BYTES(bit_stream_ptr->GetNumberOfUnreadBits());
}

auto plugin::samp::bit_stream::reset_read_pointer() -> void {
    bit_stream_ptr->ResetReadPointer();
}

auto plugin::samp::bit_stream::reset_write_pointer() -> void {
    bit_stream_ptr->ResetWritePointer();
}

auto plugin::samp::bit_stream::reset_bit_stream() -> void {
    bit_stream_ptr->Reset();
}

auto plugin::samp::bit_stream::get_read_offset() -> int {
    return bit_stream_ptr->GetReadOffset();
}

auto plugin::samp::bit_stream::get_write_offset() -> int {
    return bit_stream_ptr->GetWriteOffset();
}

auto plugin::samp::bit_stream::set_read_offset(int offset) -> void {
    bit_stream_ptr->SetReadOffset(offset);
}

auto plugin::samp::bit_stream::set_write_offset(int offset) -> void {
    bit_stream_ptr->SetWriteOffset(offset);
}

auto plugin::samp::bit_stream::ignore_bits(int count) -> void {
    bit_stream_ptr->IgnoreBits(count);
}

auto plugin::samp::bit_stream::ignore_bytes(int count) -> void {
    bit_stream_ptr->IgnoreBits(BYTES_TO_BITS(count));
}

auto plugin::samp::bit_stream::read_string(std::int32_t length) -> std::string {
    std::string result(length, '\0');
    bit_stream_ptr->Read(result.data(), length);
    return result;
}

auto plugin::samp::bit_stream::read_encoded(int length) -> std::string {
    std::string result(length, '\0');
    
    encoded_reader_container->invoke(encode_decode_base_container->read(), result.data(),
                                     length, bit_stream_ptr, 0);

    result.resize(result.find('\0'));

    return result;
}

auto plugin::samp::bit_stream::read_buffer(std::uintptr_t destination, int size) -> bool {
    return bit_stream_ptr->ReadBits(reinterpret_cast<unsigned char*>(destination), BYTES_TO_BITS(size), false);
}

auto plugin::samp::bit_stream::write(const std::string_view& value) -> void {
    bit_stream_ptr->Write(value.data(), value.size());
}

auto plugin::samp::bit_stream::write_encoded(const std::string_view& value) -> void {
    bit_stream_ptr->AddBitsAndReallocate(value.size() * 16 + 16);
    encoded_writer_container->invoke(encode_decode_base_container->read(), value.data(),
                                     value.size() + 1, bit_stream_ptr, 0);
}

auto plugin::samp::bit_stream::emulate_incoming_rpc(std::uint8_t rpc_id) -> bool {
    if (plugin::event_handler == nullptr || !plugin::event_handler->initialized || plugin::event_handler->rak_peer == nullptr)
        return false;

    BitStream send_bit_stream;

    send_bit_stream.Write<std::uint8_t>(rpc_id);
    send_bit_stream.Write(rpc_id);
    send_bit_stream.WriteCompressed<unsigned int>(bit_stream_ptr->GetNumberOfBitsUsed());
    send_bit_stream.WriteBits(bit_stream_ptr->GetData(), bit_stream_ptr->GetNumberOfBitsUsed(), false);

    auto call_trampoline = plugin::event_handler->get_incoming_rpc_trampoline();

    return call_trampoline(plugin::event_handler->rak_peer, std::bit_cast<char*>(send_bit_stream.GetData()),
                           send_bit_stream.GetNumberOfBytesUsed(), plugin::event_handler->user_id);
}

auto plugin::samp::bit_stream::emulate_incoming_packet(std::uint8_t packet_id) -> bool {
    if (plugin::event_handler == nullptr || !plugin::event_handler->initialized || plugin::event_handler->rak_peer == nullptr)
        return false;

    BitStream send_bit_stream;

    send_bit_stream.Write(packet_id);
    send_bit_stream.WriteBits(bit_stream_ptr->GetData(), bit_stream_ptr->GetNumberOfBytesUsed(), false);

    Packet* send_packet = allocate_packet_container->invoke(send_bit_stream.GetNumberOfBytesUsed());
    char* packets = static_cast<char*>(plugin::event_handler->rak_peer) + 0xDB6;

    memcpy(send_packet->data, send_bit_stream.GetData(), send_packet->length);

    *write_lock_container->invoke(packets) = send_packet;
    write_unlock_container->invoke(packets);

    return true;
}

#define RAKCLIENT_INTERFACE reinterpret_cast<std::uintptr_t>(plugin::event_handler->rak_peer) + 0xDDE

auto plugin::samp::bit_stream::send_rpc(int rpc_id) -> bool {
    if (plugin::event_handler == nullptr || !plugin::event_handler->initialized)
        return false;

    return reinterpret_cast<signatures::send_rpc_t>(plugin::event_handler->v_table[25])
        (RAKCLIENT_INTERFACE, &rpc_id, bit_stream_ptr, HIGH_PRIORITY, RELIABLE_ORDERED, 0, false); 
}

auto plugin::samp::bit_stream::send_rpc(int rpc_id, PacketPriority priority,
                                        PacketReliability reliability, std::uint8_t channel,
                                        bool timestamp) -> bool
{
    if (plugin::event_handler == nullptr || !plugin::event_handler->initialized)
        return false;

    return reinterpret_cast<signatures::send_rpc_t>(plugin::event_handler->v_table[25])
        (RAKCLIENT_INTERFACE, &rpc_id, bit_stream_ptr, priority, reliability, channel, timestamp);
}

auto plugin::samp::bit_stream::send_packet() -> bool {
    if (plugin::event_handler == nullptr || !plugin::event_handler->initialized)
        return false;

    return reinterpret_cast<signatures::send_packet_t>(plugin::event_handler->v_table[6])
        (RAKCLIENT_INTERFACE, bit_stream_ptr, HIGH_PRIORITY, UNRELIABLE_SEQUENCED, 0);
}

auto plugin::samp::bit_stream::send_packet(PacketPriority priority, PacketReliability reliability, std::uint8_t channel)
    -> bool
{
    if (plugin::event_handler == nullptr || !plugin::event_handler->initialized)
        return false;

    return reinterpret_cast<signatures::send_packet_t>(plugin::event_handler->v_table[6])
        (RAKCLIENT_INTERFACE, bit_stream_ptr, priority, reliability, channel);
}

#undef RAKCLIENT_INTERFACE

auto plugin::samp::bit_stream::get_original_bit_stream() -> BitStream* {
    return bit_stream_ptr;
}

auto plugin::samp::bit_stream::get_data_ptr() -> std::uintptr_t {
    return reinterpret_cast<std::uintptr_t>(bit_stream_ptr->GetData());
}

plugin::samp::bit_stream::~bit_stream() noexcept {
    if (bit_stream_ptr && delete_bit_stream)
        delete bit_stream_ptr;
}
