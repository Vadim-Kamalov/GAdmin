#include "plugin/samp/network/bit_stream.h"
#include "plugin/plugin.h"
#include "plugin/samp/network/address.h"
#include "plugin/signatures.h"

int
plugin::samp::BitStream::get_number_of_bits_used() {
    return bit_stream->GetNumberOfBitsUsed();
}

int
plugin::samp::BitStream::get_number_of_bytes_used() {
    return bit_stream->GetNumberOfBytesUsed();
}

int
plugin::samp::BitStream::get_number_of_unread_bits() {
    return bit_stream->GetNumberOfUnreadBits();
}

int
plugin::samp::BitStream::get_number_of_unread_bytes() {
    return BITS_TO_BYTES(bit_stream->GetNumberOfUnreadBits());
}

void
plugin::samp::BitStream::reset_read_pointer() {
    bit_stream->ResetReadPointer();
}

void
plugin::samp::BitStream::reset_write_pointer() {
    bit_stream->ResetWritePointer();
}

void
plugin::samp::BitStream::reset_bit_stream() {
    bit_stream->Reset();
}

int
plugin::samp::BitStream::get_read_offset() {
    return bit_stream->GetReadOffset();
}

int
plugin::samp::BitStream::get_write_offset() {
    return bit_stream->GetWriteOffset();
}

void
plugin::samp::BitStream::set_read_offset(int offset) {
    bit_stream->SetReadOffset(offset);
}

void
plugin::samp::BitStream::set_write_offset(int offset) {
    bit_stream->SetWriteOffset(offset);
}

void
plugin::samp::BitStream::ignore_bits(int count) {
    bit_stream->IgnoreBits(count);
}

void
plugin::samp::BitStream::ignore_bytes(int count) {
    bit_stream->IgnoreBits(BYTES_TO_BITS(count));
}

std::string
plugin::samp::BitStream::read_string(std::int32_t length) {
    std::string result(length, '\0');
    bit_stream->Read(result.data(), length);
    return result;
}

std::string
plugin::samp::BitStream::read_encoded(int length) {
    std::string result(length, '\0');
    
    reinterpret_cast<signatures::EncodedReader>(address::encoded_reader())(
        address::encode_decode_base(), result.data(), length, bit_stream, 0);

    result.resize(result.find('\0'));

    return result;
}

bool
plugin::samp::BitStream::read_buffer(std::uintptr_t destination, int size) {
    return bit_stream->ReadBits(reinterpret_cast<unsigned char*>(destination), BYTES_TO_BITS(size), false);
}

void
plugin::samp::BitStream::write(const std::string_view& value) {
    bit_stream->Write(value.data(), value.size());
}

void
plugin::samp::BitStream::write_encoded(const std::string_view& value) {
    bit_stream->AddBitsAndReallocate(value.size() * 16 + 16);
}

bool
plugin::samp::BitStream::emulate_incoming_rpc(std::uint8_t rpc_id) {
    if (!Plugin::event_handler.is_initialized() || !Plugin::event_handler.get_rak_peer())
        return false;

    ::BitStream send_bit_stream;

    send_bit_stream.Write<std::uint8_t>(ID_RPC);
    send_bit_stream.Write(rpc_id);
    send_bit_stream.WriteCompressed<unsigned int>(bit_stream->GetNumberOfBitsUsed());
    send_bit_stream.WriteBits(bit_stream->GetData(), bit_stream->GetNumberOfBitsUsed(), false);

    auto call_trampoline = Plugin::event_handler.get_incoming_rpc_trampoline();

    return call_trampoline(Plugin::event_handler.get_rak_peer(), std::bit_cast<char*>(send_bit_stream.GetData()),
                           send_bit_stream.GetNumberOfBytesUsed(), Plugin::event_handler.get_player_id());
}

bool
plugin::samp::BitStream::emulate_incoming_packet(std::uint8_t packet_id) {
    if (!Plugin::event_handler.is_initialized() || !Plugin::event_handler.get_rak_peer())
        return false;

    ::BitStream send_bit_stream;

    send_bit_stream.Write(packet_id);
    send_bit_stream.WriteBits(bit_stream->GetData(), bit_stream->GetNumberOfBytesUsed(), false);

    Packet* send_packet = reinterpret_cast<signatures::AllocatePacket>(address::allocate_packet())(send_bit_stream.GetNumberOfBytesUsed());
    memcpy(send_packet->data, send_bit_stream.GetData(), send_packet->length);
    {
        char* packets = static_cast<char*>(Plugin::event_handler.get_rak_peer()) + 0xDB6;
        auto write_lock = reinterpret_cast<signatures::WriteLock>(address::write_lock());
        auto write_unlock = reinterpret_cast<signatures::WriteUnlock>(address::write_unlock());

        *write_lock(packets) = send_packet;
        write_unlock(packets);
    }

    return true;
}

#define RAKCLIENT_INTERFACE reinterpret_cast<std::uintptr_t>(Plugin::event_handler.get_rak_peer()) + 0xDDE

bool
plugin::samp::BitStream::send_rpc(int rpc_id) {
    if (!Plugin::event_handler.is_initialized())
        return false;

    return reinterpret_cast<signatures::SendRPC>(Plugin::event_handler.get_v_table()[25])
        (RAKCLIENT_INTERFACE, &rpc_id, bit_stream, HIGH_PRIORITY, RELIABLE_ORDERED, 0, false); 
}

bool
plugin::samp::BitStream::send_rpc(int rpc_id, PacketPriority priority, PacketReliability reliability, std::uint8_t channel, bool timestamp) {
    if (!Plugin::event_handler.is_initialized())
        return false;

    return reinterpret_cast<signatures::SendRPC>(Plugin::event_handler.get_v_table()[25])
        (RAKCLIENT_INTERFACE, &rpc_id, bit_stream, priority, reliability, channel, timestamp);
}

bool
plugin::samp::BitStream::send_packet() {
    if (!Plugin::event_handler.is_initialized())
        return false;

    return reinterpret_cast<signatures::SendPacket>(Plugin::event_handler.get_v_table()[6])
        (RAKCLIENT_INTERFACE, bit_stream, HIGH_PRIORITY, UNRELIABLE_SEQUENCED, 0);
}

bool
plugin::samp::BitStream::send_packet(PacketPriority priority, PacketReliability reliability, std::uint8_t channel) {
    if (!Plugin::event_handler.is_initialized())
        return false;

    return reinterpret_cast<signatures::SendPacket>(Plugin::event_handler.get_v_table()[6])
        (RAKCLIENT_INTERFACE, bit_stream, priority, reliability, channel);
}

#undef RAKCLIENT_INTERFACE

BitStream*
plugin::samp::BitStream::get_original_bit_stream() {
    return bit_stream;
}

std::uintptr_t
plugin::samp::BitStream::get_data_ptr() {
    return reinterpret_cast<std::uintptr_t>(bit_stream->GetData());
}

plugin::samp::BitStream::~BitStream() {
    if (bit_stream && delete_bit_stream)
        delete bit_stream;
}
