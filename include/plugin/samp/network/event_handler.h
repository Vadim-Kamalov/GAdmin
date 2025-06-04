#ifndef GADMIN_PLUGIN_SAMP_NETWORK_EVENT_HANDLER_H
#define GADMIN_PLUGIN_SAMP_NETWORK_EVENT_HANDLER_H

#include "plugin/samp/events/event.h"
#include "plugin/samp/network/signatures.h"
#include "plugin/types/simple.h"
#include "raknet/rak_client.h"
#include <chrono>
#include <kthook/kthook.hpp>
#include <functional>

namespace plugin::samp {

class event_handler final {
public:
    using callback_t = std::function<bool(const event_info&)>;
private:
    static constexpr std::uint32_t max_alloca_stack_allocation = 0x100000;
    static constexpr std::uint8_t timestamp_rpc_id = 40;

    std::optional<callback_t> callback;

    bool paused = false;
    std::chrono::steady_clock::time_point time_left_from_pause;

    kthook::kthook_simple<signatures::rak_client_interface_constructor_t> rak_client_interface_constructor_hook;
    kthook::kthook_simple<signatures::incoming_rpc_handler_t> incoming_rpc_handler_hook;
    kthook::kthook_simple<signatures::outgoing_packet_handler_t> outgoing_packet_handler_hook;
    kthook::kthook_simple<signatures::incoming_packet_handler_t> incoming_packet_handler_hook;
    kthook::kthook_simple<signatures::outgoing_rpc_handler_t> outgoing_rpc_handler_hook;

    auto can_process_event() const -> bool;
    auto rak_client_interface_constructor_hooked(const decltype(rak_client_interface_constructor_hook)& hook) -> std::uintptr_t;

    auto incoming_rpc_handler_hooked(const decltype(incoming_rpc_handler_hook)& hook, void* ptr, types::zstring_t data,
                                     int length, PlayerID player_id) -> bool;

    auto outgoing_packet_handler_hooked(const decltype(outgoing_packet_handler_hook)& hook, void* ptr, BitStream* bit_stream,
                                        PacketPriority priority, PacketReliability reliability, char ordering_channel) -> bool;

    auto incoming_packet_handler_hooked(const decltype(incoming_packet_handler_hook)& hook, void* ptr) -> Packet*;

    auto outgoing_rpc_handler_hooked(const decltype(outgoing_rpc_handler_hook)& hook, void* ptr, int* id,
                                     BitStream* bit_stream, PacketPriority priority, PacketReliability reliability,
                                     char ordering_channel, bool shift_timestamp) -> bool;
public:
    void** v_table = nullptr;
    void* rak_peer = nullptr;
    bool initialized = false;
    PlayerID user_id;
    
    auto get_incoming_rpc_trampoline() const -> signatures::incoming_rpc_handler_t;
    auto attach(callback_t new_callback) -> void;
    auto main_loop() -> void;
}; // class event_handler final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_NETWORK_EVENT_HANDLER_H
