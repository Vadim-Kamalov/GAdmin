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

#ifndef GADMIN_PLUGIN_SAMP_NETWORK_EVENT_HANDLER_H
#define GADMIN_PLUGIN_SAMP_NETWORK_EVENT_HANDLER_H

#include "plugin/samp/events/event.h"
#include "plugin/types/address.h"
#include "plugin/types/simple.h"
#include "raknet/rak_client.h"
#include <chrono>
#include <kthook/kthook.hpp>
#include <functional>

namespace plugin {
namespace signatures {

using rak_client_interface_constructor_t = std::uintptr_t(*)();
using incoming_rpc_handler_t = bool(__thiscall*)(void*, types::zstring_t, int, PlayerID);
using outgoing_packet_handler_t = bool(__thiscall*)(void*, BitStream*, PacketPriority, PacketReliability, char);
using incoming_packet_handler_t = Packet*(__thiscall*)(void*);
using outgoing_rpc_handler_t = bool(__thiscall*)(void*, int*, BitStream*, PacketPriority, PacketReliability, char, bool);
using dealocate_packet_t = void(__thiscall*)(void*, Packet*);

} // namespace signatures

namespace samp {

/// Represents an event handler. Intercepts events sent by the
/// SA:MP client or user and transmits them to the plugin.
class event_handler final {
public:
    /// Callback function for receiving events.
    using callback_t = std::function<bool(const event_info&)>;
private:
    static constexpr std::uint32_t max_alloca_stack_allocation = 0x100000;
    static constexpr std::uint8_t timestamp_rpc_id = 40;

    static types::versioned_address_container<std::uintptr_t> rak_client_interface_constructor_container;
    static types::versioned_address_container<std::uintptr_t> incoming_rpc_handler_container;

    bool paused = false;
    std::optional<callback_t> callback;
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
    void** v_table = nullptr; ///< Pointer to the `RakClientInterface` virtual method table.
    void* rak_peer = nullptr; ///< Pointer to the `RakPeer` object.
    bool initialized = false; ///< Whether event handler is initialized.
    PlayerID user_id;         ///< User ID.
    
    /// Get trampoline to the incoming RPC handler.
    ///
    /// @return Trampoline to the incoming RPC handler.
    auto get_incoming_rpc_trampoline() const -> signatures::incoming_rpc_handler_t;
    
    /// Set new callback function which will accept intercepted events.
    /// 
    /// @param new_callback[in] New callback function.
    auto set_callback(callback_t new_callback) -> void;

    /// Main loop for the event handler.
    auto main_loop() -> void;
}; // class event_handler final

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_NETWORK_EVENT_HANDLER_H
