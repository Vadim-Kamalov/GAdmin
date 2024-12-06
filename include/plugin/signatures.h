#ifndef GADMIN_PLUGIN_SIGNATURES_H
#define GADMIN_PLUGIN_SIGNATURES_H

#include "raknet/bit_stream.h"
#include "raknet/rak_client.h"
#include <d3d9.h>
#include <windows.h>
#include <cstdint>

namespace plugin::signatures {

using GameLoop = void(__cdecl*)();
using D3D9Present = HRESULT(__stdcall*)(IDirect3DDevice9*, const RECT*, const RECT*, HWND, const RGNDATA*);
using D3D9Reset = HRESULT(__stdcall*)(IDirect3DDevice9*, D3DPRESENT_PARAMETERS*);
using WndProc = LRESULT(__stdcall*)(HWND, UINT, WPARAM, LPARAM);

using RakClientInterfaceConstructor = std::uintptr_t(*)();
using IncomingRpcHandler = bool(__thiscall*)(void*, const char*, int, PlayerID);
using OutgoingPacketHandler = bool(__thiscall*)(void*, BitStream*, PacketPriority, PacketReliability, char);
using IncomingPacketHandler = Packet*(__thiscall*)(void*);
using OutgoingRpcHandler = bool(__thiscall*)(void*, int*, BitStream*, PacketPriority, PacketReliability, char, bool);
using DealocatePacket = void(__thiscall*)(void*, Packet*);
using EncodedReader = bool(__thiscall*)(std::uintptr_t, char*, int, BitStream* bit_stream, int);
using EncodedWriter = void(__thiscall*)(std::uintptr_t, const char*, int, BitStream*, int);
using AllocatePacket = Packet*(*)(int);
using WriteLock = Packet**(__thiscall*)(void*);
using WriteUnlock = void(__thiscall*)(void*);
using SendRPC = bool(__thiscall*)(std::uintptr_t, int*, BitStream*, PacketPriority, PacketReliability, char, bool);
using SendPacket = bool(__thiscall*)(std::uintptr_t, BitStream*, PacketPriority, PacketReliability, char);

} // namespace plugin::signatures

#endif // GADMIN_PLUGIN_SIGNATURES_H
