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

#include "plugin/samp/network/event_handler.h"
#include "plugin/game/game.h"
#include "plugin/samp/events/event.h"
#include "plugin/samp/network/bit_stream.h"
#include "plugin/samp/samp.h"
#include "plugin/log.h"
#include <cstdint>

plugin::types::versioned_address_container<std::uintptr_t>
plugin::samp::event_handler::rak_client_interface_constructor_container = { 0x33DC0, 0x37170, 0x378B0, 0x37370 };

plugin::types::versioned_address_container<std::uintptr_t>
plugin::samp::event_handler::incoming_rpc_handler_container = { 0x372F0, 0x3A6A0, 0x3ADE0, 0x3A8A0 };

auto plugin::samp::event_handler::can_process_event() const -> bool {
    using namespace std::chrono_literals;
    return std::chrono::steady_clock::now() - time_left_from_pause >= 500ms;
}

auto plugin::samp::event_handler::rak_client_interface_constructor_hooked(const decltype(rak_client_interface_constructor_hook)& hook)
    -> std::uintptr_t
{
    using namespace std::placeholders;

    std::uintptr_t rak_client_interface = hook.call_trampoline();

    if (rak_client_interface) {
        rak_peer = reinterpret_cast<void*>(rak_client_interface - 0xDDE);

        incoming_rpc_handler_hook.set_dest(**incoming_rpc_handler_container);
        incoming_rpc_handler_hook.set_cb(std::bind(&event_handler::incoming_rpc_handler_hooked, this, _1, _2, _3, _4, _5));
        incoming_rpc_handler_hook.install();

        v_table = *reinterpret_cast<void***>(rak_client_interface);

        outgoing_packet_handler_hook.set_dest(v_table[6]);
        outgoing_packet_handler_hook.set_cb(std::bind(&event_handler::outgoing_packet_handler_hooked, this, _1, _2, _3, _4, _5, _6));
        outgoing_packet_handler_hook.install();

        incoming_packet_handler_hook.set_dest(v_table[8]);
        incoming_packet_handler_hook.set_cb(std::bind(&event_handler::incoming_packet_handler_hooked, this, _1, _2));
        incoming_packet_handler_hook.install();

        outgoing_rpc_handler_hook.set_dest(v_table[25]);
        outgoing_rpc_handler_hook.set_cb(std::bind(&event_handler::outgoing_rpc_handler_hooked, this, _1, _2, _3, _4, _5, _6, _7, _8));
        outgoing_rpc_handler_hook.install();

        log::info("installed hooks on the next handlers: incoming_rpc, outgoing_rpc, incoming_packet, outgoing_packet");
    }

    return rak_client_interface;
}

auto plugin::samp::event_handler::incoming_rpc_handler_hooked(const decltype(incoming_rpc_handler_hook)& hook, void* ptr,
                                                              types::zstring_t data, int length, PlayerID player_id) -> bool
{
    user_id = player_id;

    std::uint8_t id = 0;
    std::uint32_t bits_data = 0;
    unsigned char* input = nullptr;
    std::unique_ptr<BitStream> callback_stream = std::make_unique<BitStream>();

    BitStream stream(std::bit_cast<unsigned char*>(const_cast<char*>(data)), length, true);
    stream.IgnoreBits(8);

    if (data[0] == timestamp_rpc_id)
        stream.IgnoreBits(8 * (sizeof(RakNetTime) + sizeof(unsigned char)));

    int offset = stream.GetReadOffset();

    stream.Read(id);

    if (!can_process_event())
        return hook.call_trampoline(ptr, data, length, player_id);

    if (!stream.ReadCompressed(bits_data))
        return false;

    if (bits_data) {
        bool used_alloca = false;

        if (BITS_TO_BYTES(stream.GetNumberOfUnreadBits()) < max_alloca_stack_allocation) {
            input = reinterpret_cast<unsigned char*>(alloca(BITS_TO_BYTES(stream.GetNumberOfUnreadBits())));
            used_alloca = true;
        } else
            input = new unsigned char[BITS_TO_BYTES(stream.GetNumberOfUnreadBits())];

        if (!stream.ReadBits(input, bits_data, false)) {
            if (!used_alloca)
                delete[] input;
            return false;
        }

        callback_stream = std::make_unique<BitStream>(input, BITS_TO_BYTES(bits_data), true);

        if (!used_alloca)
            delete[] input;
    }

    bit_stream new_stream(callback_stream.get());
    new_stream.reset_read_pointer();

    if (callback.has_value() && !(*callback)(event_info(event_type::incoming_rpc, id, &new_stream)))
        return false;

    stream.SetWriteOffset(offset);
    stream.Write(id);
    
    bits_data = callback_stream->GetNumberOfBitsUsed();

    stream.WriteCompressed(bits_data);

    if (bits_data)
        stream.WriteBits(callback_stream->GetData(), bits_data, false);

    return hook.call_trampoline(ptr, std::bit_cast<char*>(stream.GetData()), stream.GetNumberOfBytesUsed(), player_id);
}

auto plugin::samp::event_handler::outgoing_packet_handler_hooked(const decltype(outgoing_packet_handler_hook)& hook, void* ptr, BitStream* stream,
                                                                 PacketPriority priority, PacketReliability reliability, char ordering_channel)
    -> bool
{
    bit_stream new_stream(stream);
    std::uint8_t event_id = new_stream.read<std::uint8_t>();

    if (!can_process_event())
        return hook.call_trampoline(ptr, stream, priority, reliability, ordering_channel);

    if (callback.has_value()) {
        new_stream.reset_read_pointer();
        if (!(*callback)(event_info(event_type::outgoing_packet, event_id, &new_stream)))
            return false;
    }

    new_stream.reset_read_pointer();

    return hook.call_trampoline(ptr, stream, priority, reliability, ordering_channel);
}

auto plugin::samp::event_handler::incoming_packet_handler_hooked(const decltype(incoming_packet_handler_hook)& hook, void* ptr) -> Packet* {
    Packet* packet = hook.call_trampoline(ptr);

    if (packet == nullptr || packet->data == nullptr || packet->length == 0 || packet->bitSize == 0)
        return nullptr;

    bit_stream new_stream(packet->data, packet->bitSize, false);
    std::uint8_t id = new_stream.read<std::uint8_t>();

    if (!can_process_event())
        return packet;

    if (callback.has_value()) {
        while (packet) {
            if ((*callback)(event_info(event_type::incoming_packet, id, &new_stream)))
                break;

            reinterpret_cast<signatures::dealocate_packet_t>(v_table[9])(ptr, packet);

            packet = hook.call_trampoline(ptr);
        }
    }

    if (packet) {
        packet->bitSize = new_stream.get_number_of_bits_used();
        packet->length = new_stream.get_number_of_bytes_used();
    }

    return packet;
}

auto plugin::samp::event_handler::outgoing_rpc_handler_hooked(const decltype(outgoing_rpc_handler_hook)& hook, void* ptr, int* id,
                                                              BitStream* stream, PacketPriority priority, PacketReliability reliability,
                                                              char ordering_channel, bool shift_timestamp)
    -> bool
{
    if (!can_process_event())
        return hook.call_trampoline(ptr, id, stream, priority, reliability, ordering_channel, shift_timestamp);

    bit_stream new_stream(stream);
    new_stream.reset_read_pointer();

    if (callback.has_value() && !(*callback)(event_info(event_type::outgoing_rpc, *id, &new_stream)))
        return false;

    new_stream.reset_read_pointer();

    return hook.call_trampoline(ptr, id, stream, priority, reliability, ordering_channel, shift_timestamp);
}

auto plugin::samp::event_handler::get_incoming_rpc_trampoline() const -> signatures::incoming_rpc_handler_t {
    return incoming_rpc_handler_hook.get_trampoline();
}

auto plugin::samp::event_handler::set_callback(callback_t new_callback) -> void {
    callback = std::move(new_callback);
}

auto plugin::samp::event_handler::main_loop() -> void {
    bool menu_opened = game::is_menu_opened();

    if (!menu_opened && paused)
        time_left_from_pause = std::chrono::steady_clock::now();

    paused = menu_opened;

    if (initialized || !get_base() || get_version() == version::unknown)
        return;

    rak_client_interface_constructor_hook.set_dest(**rak_client_interface_constructor_container);
    rak_client_interface_constructor_hook.set_cb(std::bind(&event_handler::rak_client_interface_constructor_hooked, this, std::placeholders::_1));
    rak_client_interface_constructor_hook.install();

    log::info("hook \"RakClientInterface::RakClientInterface()\" installed");

    initialized = true;
}
