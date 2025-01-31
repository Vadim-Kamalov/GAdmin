#ifndef GADMIN_PLUGIN_SAMP_NETWORK_EVENT_HANDLER_H
#define GADMIN_PLUGIN_SAMP_NETWORK_EVENT_HANDLER_H

#include "plugin/samp/network/bit_stream.h"
#include "plugin/samp/network/signatures.h"
#include "plugin/utils.h"
#include "raknet/rak_client.h"
#include <kthook/kthook.hpp>
#include <functional>

#define ID_TIMESTAMP 40
#define MAX_ALLOCA_STACK_ALLOCATION 0x100000
#define ID_RPC 20

namespace plugin::samp {

enum class event_type {
    incoming_rpc,
    outgoing_rpc,
    incoming_packet,
    outgoing_packet
}; // enum class event_type

class event_handler {
private:
    void** v_table;
    void* rak_peer;
    PlayerID user_id;
    bool initialized = false;

    std::optional<std::function<bool(event_type, std::uint8_t, bit_stream*)>> callback;

    kthook::kthook_simple<signatures::rak_client_interface_constructor_t> rak_client_interface_constructor_hook;
    kthook::kthook_simple<signatures::incoming_rpc_handler_t> incoming_rpc_handler_hook;
    kthook::kthook_simple<signatures::outgoing_packet_handler_t> outgoing_packet_handler_hook;
    kthook::kthook_simple<signatures::incoming_packet_handler_t> incoming_packet_handler_hook;
    kthook::kthook_simple<signatures::outgoing_rpc_handler_t> outgoing_rpc_handler_hook;

    std::uintptr_t rak_client_interface_constructor_hooked(const decltype(rak_client_interface_constructor_hook)& hook);

    bool incoming_rpc_handler_hooked(const decltype(incoming_rpc_handler_hook)& hook, void* ptr, utils::zstring_t data,
                                     int length, PlayerID player_id);

    bool outgoing_packet_handler_hooked(const decltype(outgoing_packet_handler_hook)& hook, void* ptr, BitStream* bit_stream,
                                        PacketPriority priority, PacketReliability reliability, char ordering_channel);

    Packet* incoming_packet_handler_hooked(const decltype(incoming_packet_handler_hook)& hook, void* ptr);

    bool outgoing_rpc_handler_hooked(const decltype(outgoing_rpc_handler_hook)& hook, void* ptr, int* id,
                                     BitStream* bit_stream, PacketPriority priority, PacketReliability reliability,
                                     char ordering_channel, bool shift_timestamp);
public:
    constexpr void** get_v_table() const { return v_table; }
    constexpr void* get_rak_peer() const { return rak_peer; }
    constexpr PlayerID get_player_id() const { return user_id; }
    constexpr bool is_initialized() const { return initialized; }
    constexpr signatures::incoming_rpc_handler_t get_incoming_rpc_trampoline() const { return incoming_rpc_handler_hook.get_trampoline(); }

    void attach(std::function<bool(event_type, std::uint8_t, bit_stream*)> callback);
    bool initialize();
}; // class event_handler

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_NETWORK_EVENT_HANDLER_H
