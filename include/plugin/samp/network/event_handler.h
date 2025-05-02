#ifndef GADMIN_PLUGIN_SAMP_NETWORK_EVENT_HANDLER_H
#define GADMIN_PLUGIN_SAMP_NETWORK_EVENT_HANDLER_H

#include "plugin/samp/events/event.h"
#include "plugin/samp/network/signatures.h"
#include "plugin/types/simple.h"
#include "raknet/rak_client.h"
#include <chrono>
#include <kthook/kthook.hpp>
#include <functional>

#define ID_TIMESTAMP 40
#define MAX_ALLOCA_STACK_ALLOCATION 0x100000
#define ID_RPC 20

namespace plugin::samp {

class event_handler {
public:
    using callback_t = std::function<bool(const event_info&)>;
private:
    std::optional<callback_t> callback;

    bool paused = false;
    std::chrono::steady_clock::time_point time_left_from_pause;

    kthook::kthook_simple<signatures::rak_client_interface_constructor_t> rak_client_interface_constructor_hook;
    kthook::kthook_simple<signatures::incoming_rpc_handler_t> incoming_rpc_handler_hook;
    kthook::kthook_simple<signatures::outgoing_packet_handler_t> outgoing_packet_handler_hook;
    kthook::kthook_simple<signatures::incoming_packet_handler_t> incoming_packet_handler_hook;
    kthook::kthook_simple<signatures::outgoing_rpc_handler_t> outgoing_rpc_handler_hook;

    bool can_process_event() const;

    std::uintptr_t rak_client_interface_constructor_hooked(const decltype(rak_client_interface_constructor_hook)& hook);

    bool incoming_rpc_handler_hooked(const decltype(incoming_rpc_handler_hook)& hook, void* ptr, types::zstring_t data,
                                     int length, PlayerID player_id);

    bool outgoing_packet_handler_hooked(const decltype(outgoing_packet_handler_hook)& hook, void* ptr, BitStream* bit_stream,
                                        PacketPriority priority, PacketReliability reliability, char ordering_channel);

    Packet* incoming_packet_handler_hooked(const decltype(incoming_packet_handler_hook)& hook, void* ptr);

    bool outgoing_rpc_handler_hooked(const decltype(outgoing_rpc_handler_hook)& hook, void* ptr, int* id,
                                     BitStream* bit_stream, PacketPriority priority, PacketReliability reliability,
                                     char ordering_channel, bool shift_timestamp);
public:
    void** v_table = nullptr;
    void* rak_peer = nullptr;
    bool initialized = false;
    PlayerID user_id;
    
    signatures::incoming_rpc_handler_t get_incoming_rpc_trampoline() const;

    void attach(callback_t new_callback);
    void main_loop();
}; // class event_handler

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_NETWORK_EVENT_HANDLER_H
