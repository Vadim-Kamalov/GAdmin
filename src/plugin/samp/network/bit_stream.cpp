#include "plugin/samp/network/bit_stream.h"
#include "plugin/samp/network/address.h"
#include "plugin/samp/network/signatures.h"
#include "plugin/plugin.h"

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
    
    reinterpret_cast<signatures::encoded_reader_t>(address::encoded_reader())
        (address::encode_decode_base(), result.data(), length, bit_stream_ptr, 0);

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
    reinterpret_cast<signatures::encoded_writer_t>(address::encoded_writer())
        (address::encode_decode_base(), value.data(), value.size() + 1, bit_stream_ptr, 0);
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

    Packet* send_packet = reinterpret_cast<signatures::allocate_packet_t>(address::allocate_packet())
        (send_bit_stream.GetNumberOfBytesUsed());
    
    memcpy(send_packet->data, send_bit_stream.GetData(), send_packet->length);
    
    char* packets = static_cast<char*>(plugin::event_handler->rak_peer) + 0xDB6;
    auto write_lock = reinterpret_cast<signatures::write_lock_t>(address::write_lock());
    auto write_unlock = reinterpret_cast<signatures::write_unlock_t>(address::write_unlock());

    *write_lock(packets) = send_packet;
    write_unlock(packets);

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
