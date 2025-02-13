#ifndef GADMIN_PLUGIN_SAMP_NETWORK_SIGNATURES_H
#define GADMIN_PLUGIN_SAMP_NETWORK_SIGNATURES_H

#include "plugin/types/simple.h"
#include "raknet/bit_stream.h"
#include "raknet/rak_client.h"
#include <cstdint>

namespace plugin::signatures {

using rak_client_interface_constructor_t = std::uintptr_t(*)();
using incoming_rpc_handler_t = bool(__thiscall*)(void*, types::zstring_t, int, PlayerID);
using outgoing_packet_handler_t = bool(__thiscall*)(void*, BitStream*, PacketPriority, PacketReliability, char);
using incoming_packet_handler_t = Packet*(__thiscall*)(void*);
using outgoing_rpc_handler_t = bool(__thiscall*)(void*, int*, BitStream*, PacketPriority, PacketReliability, char, bool);
using dealocate_packet_t = void(__thiscall*)(void*, Packet*);
using encoded_reader_t = bool(__thiscall*)(std::uintptr_t, char*, int, BitStream* bit_stream, int);
using encoded_writer_t = void(__thiscall*)(std::uintptr_t, types::zstring_t, int, BitStream*, int);
using allocate_packet_t = Packet*(*)(int);
using write_lock_t = Packet**(__thiscall*)(void*);
using write_unlock_t = void(__thiscall*)(void*);
using send_rpc_t = bool(__thiscall*)(std::uintptr_t, int*, BitStream*, PacketPriority, PacketReliability, char, bool);
using send_packet_t = bool(__thiscall*)(std::uintptr_t, BitStream*, PacketPriority, PacketReliability, char);

} // namespace plugin::signatures

#endif // GADMIN_PLUGIN_SAMP_NETWORK_SIGNATURES_H
