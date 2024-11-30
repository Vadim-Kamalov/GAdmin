#ifndef GADMIN_PLUGIN_SAMP_NETWORK_EVENT_HANDLER_H
#define GADMIN_PLUGIN_SAMP_NETWORK_EVENT_HANDLER_H

#include "plugin/samp/network/bit_stream.h"
#include "plugin/signatures.h"
#include "raknet/rak_client.h"
#include <functional>
#include <kthook/kthook.hpp>

#define ID_TIMESTAMP 40
#define MAX_ALLOCA_STACK_ALLOCATION 1048576
#define ID_RPC 20

namespace plugin::samp {

enum class EventType {
    IncomingRPC,
    OutgoingRPC,
    IncomingPacket,
    OutgoingPacket
}; // enum class EventType

class EventHandler {
private:
    void** v_table;
    void* rak_peer;
    PlayerID user_id;
    bool initialized = false;

    std::optional<std::function<bool(EventType, std::uint8_t, BitStream*)>> callback;

    kthook::kthook_simple<signatures::RakClientInterfaceConstructor> rak_client_interface_constructor_hook;
    kthook::kthook_simple<signatures::IncomingRpcHandler> incoming_rpc_handler_hook;
    kthook::kthook_simple<signatures::OutgoingPacketHandler> outgoing_packet_handler_hook;
    kthook::kthook_simple<signatures::IncomingPacketHandler> incoming_packet_handler_hook;
    kthook::kthook_simple<signatures::OutgoingRpcHandler> outgoing_rpc_handler_hook;

    std::uintptr_t rak_client_interface_constructor_hooked(const decltype(rak_client_interface_constructor_hook)& hook);

    bool incoming_rpc_handler_hooked(const decltype(incoming_rpc_handler_hook)& hook, void* ptr, const char* data,
                                     int length, PlayerID player_id);

    bool outgoing_packet_handler_hooked(const decltype(outgoing_packet_handler_hook)& hook, void* ptr, ::BitStream* bit_stream,
                                        PacketPriority priority, PacketReliability reliability, char ordering_channel);

    Packet* incoming_packet_handler_hooked(const decltype(incoming_packet_handler_hook)& hook, void* ptr);

    bool outgoing_rpc_handler_hooked(const decltype(outgoing_rpc_handler_hook)& hook, void* ptr, int* id,
                                     ::BitStream* bit_stream, PacketPriority priority, PacketReliability reliability,
                                     char ordering_channel, bool shift_timestamp);
public:
    constexpr void** get_v_table() const { return v_table; }
    constexpr void* get_rak_peer() const { return rak_peer; }
    constexpr PlayerID get_player_id() const { return user_id; }
    constexpr bool is_initialized() const { return initialized; }
    constexpr signatures::IncomingRpcHandler get_incoming_rpc_trampoline() const { return incoming_rpc_handler_hook.get_trampoline(); }

    void attach(const std::function<bool(EventType, std::uint8_t, BitStream*)>& callback);
    bool initialize();
}; // class EventHandler

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_NETWORK_EVENT_HANDLER_H
