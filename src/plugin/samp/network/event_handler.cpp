#include "plugin/samp/network/event_handler.h"
#include "plugin/samp/samp.h"
#include "plugin/samp/network/address.h"
#include "plugin/log.h"
#include <cstdint>

std::uintptr_t
plugin::samp::EventHandler::rak_client_interface_constructor_hooked(const decltype(rak_client_interface_constructor_hook)& hook) {
    using namespace std::placeholders;

    std::uintptr_t rak_client_interface = hook.call_trampoline();

    if (rak_client_interface) {
        rak_peer = reinterpret_cast<void*>(rak_client_interface - 0xDDE);

        incoming_rpc_handler_hook.set_dest(address::incoming_rpc_handler());
        incoming_rpc_handler_hook.set_cb(std::bind(&EventHandler::incoming_rpc_handler_hooked, this, _1, _2, _3, _4, _5));
        incoming_rpc_handler_hook.install();

        v_table = *reinterpret_cast<void***>(rak_client_interface);

        outgoing_packet_handler_hook.set_dest(v_table[6]);
        outgoing_packet_handler_hook.set_cb(std::bind(&EventHandler::outgoing_packet_handler_hooked, this, _1, _2, _3, _4, _5, _6));
        outgoing_packet_handler_hook.install();

        incoming_packet_handler_hook.set_dest(v_table[8]);
        incoming_packet_handler_hook.set_cb(std::bind(&EventHandler::incoming_packet_handler_hooked, this, _1, _2));
        incoming_packet_handler_hook.install();

        outgoing_rpc_handler_hook.set_dest(v_table[25]);
        outgoing_rpc_handler_hook.set_cb(std::bind(&EventHandler::outgoing_rpc_handler_hooked, this, _1, _2, _3, _4, _5, _6, _7, _8));
        outgoing_rpc_handler_hook.install();

        log::info("installed hooks on the next handlers: IncomingRPC, OutgoingRPC, IncomingPacket, OutgoingPacket");
    }

    return rak_client_interface;
}

bool
plugin::samp::EventHandler::incoming_rpc_handler_hooked(const decltype(incoming_rpc_handler_hook)& hook, void* ptr, const char* data,
                                                        int length, PlayerID player_id)
{
    user_id = player_id;

    std::uint8_t id = 0;
    std::uint32_t bits_data = 0;
    unsigned char* input = nullptr;
    std::unique_ptr<::BitStream> callback_bit_stream = std::make_unique<::BitStream>();

    ::BitStream bit_stream(std::bit_cast<unsigned char*>(const_cast<char*>(data)) , length, true);
    bit_stream.IgnoreBits(8);

    if (data[0] == ID_TIMESTAMP)
        bit_stream.IgnoreBits(8 * (sizeof(RakNetTime) + sizeof(unsigned char)));

    int offset = bit_stream.GetReadOffset();

    bit_stream.Read(id);

    if (!bit_stream.ReadCompressed(bits_data))
        return false;

    if (bits_data) {
        bool used_alloca = false;

        if (BITS_TO_BYTES(bit_stream.GetNumberOfUnreadBits()) < MAX_ALLOCA_STACK_ALLOCATION) {
            input = reinterpret_cast<unsigned char*>(alloca(BITS_TO_BYTES(bit_stream.GetNumberOfUnreadBits())));
            used_alloca = true;
        } else
            input = new unsigned char[BITS_TO_BYTES(bit_stream.GetNumberOfUnreadBits())];

        if (!bit_stream.ReadBits(input, bits_data, false)) {
            if (!used_alloca)
                delete[] input;
            return false;
        }

        callback_bit_stream = std::make_unique<::BitStream>(input, BITS_TO_BYTES(bits_data), true);

        if (!used_alloca)
            delete[] input;
    }

    BitStream new_bit_stream(callback_bit_stream.get());
    new_bit_stream.reset_read_pointer();

    if (callback.has_value() && !(*callback)(EventType::IncomingRPC, id, &new_bit_stream))
        return false;

    bit_stream.SetWriteOffset(offset);
    bit_stream.Write(id);
    
    bits_data = callback_bit_stream->GetNumberOfBitsUsed();

    bit_stream.WriteCompressed(bits_data);

    if (bits_data)
        bit_stream.WriteBits(callback_bit_stream->GetData(), bits_data, false);

    return hook.call_trampoline(ptr, std::bit_cast<char*>(bit_stream.GetData()), bit_stream.GetNumberOfBytesUsed(), player_id);
}

bool
plugin::samp::EventHandler::outgoing_packet_handler_hooked(const decltype(outgoing_packet_handler_hook)& hook, void* ptr, ::BitStream* bit_stream,
                                                           PacketPriority priority, PacketReliability reliability, char ordering_channel)
{
    BitStream new_bit_stream(bit_stream);
    std::uint8_t event_id = new_bit_stream.read<std::uint8_t>();

    if (callback.has_value()) {
        new_bit_stream.reset_read_pointer();
        if (!(*callback)(EventType::OutgoingPacket, event_id, &new_bit_stream))
            return false;
    }

    new_bit_stream.reset_read_pointer();

    return hook.call_trampoline(ptr, bit_stream, priority, reliability, ordering_channel);
}

Packet*
plugin::samp::EventHandler::incoming_packet_handler_hooked(const decltype(incoming_packet_handler_hook)& hook, void* ptr) {
    Packet* packet = hook.call_trampoline(ptr);

    if (!packet || !packet->data || packet->length == 0 || packet->bitSize == 0)
        return nullptr;

    BitStream new_bit_stream(packet->data, packet->bitSize, false);
    std::uint8_t id = new_bit_stream.read<std::uint8_t>();

    if (callback.has_value()) {
        while (packet) {
            if ((*callback)(EventType::IncomingPacket, id, &new_bit_stream))
                break;

            reinterpret_cast<signatures::DealocatePacket>(v_table[9])(ptr, packet);

            packet = hook.call_trampoline(ptr);
        }
    }

    if (packet) {
        packet->bitSize = new_bit_stream.get_number_of_bits_used();
        packet->length = new_bit_stream.get_number_of_bytes_used();
    }

    return packet;
}

bool
plugin::samp::EventHandler::outgoing_rpc_handler_hooked(const decltype(outgoing_rpc_handler_hook)& hook, void* ptr, int* id,
                                                        ::BitStream* bit_stream, PacketPriority priority, PacketReliability reliability,
                                                        char ordering_channel, bool shift_timestamp)
{
    BitStream new_bit_stream(bit_stream);
    new_bit_stream.reset_read_pointer();

    if (callback.has_value() && !(*callback)(EventType::OutgoingRPC, *id, &new_bit_stream))
        return false;

    new_bit_stream.reset_read_pointer();

    return hook.call_trampoline(ptr, id, bit_stream, priority, reliability, ordering_channel, shift_timestamp);
}

void
plugin::samp::EventHandler::attach(const std::function<bool(EventType, std::uint8_t, BitStream*)>& new_callback) {
    callback = new_callback;
}

bool
plugin::samp::EventHandler::initialize() {
    if (initialized)
        return true;

    if (!get_base())
        return false;

    if (get_version() == Version::Unknown)
        return false;

    rak_client_interface_constructor_hook.set_dest(address::rak_client_interface_constructor());
    rak_client_interface_constructor_hook.set_cb(std::bind(&EventHandler::rak_client_interface_constructor_hooked, this, std::placeholders::_1));
    rak_client_interface_constructor_hook.install();

    log::info("hook \"RakClientInterface::RakClientInterface()\" installed");

    initialized = true;

    return true;
}
