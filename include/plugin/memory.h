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

#ifndef GADMIN_PLUGIN_MEMORY_H
#define GADMIN_PLUGIN_MEMORY_H

#include <array>
#include <memoryapi.h>
#include <minwindef.h>
#include <vector>
#include <cstdint>

namespace plugin::memory { // Author: https://gitlab.com/SR_team/llmo/-/blob/master/memsafe.h

void* copy(void* dest, const void* src, std::size_t length);
void* copy(void* dest, const std::vector<unsigned char>& src);
void* copy(std::size_t dest, const std::size_t src, std::size_t length);
void* copy(std::size_t dest, const std::vector<unsigned char>& src);

int compare(const void* _s1, const void* _s2, uint32_t length);
int compare(const void* _s1, const std::vector<unsigned char>& _s2);
int compare(const std::size_t _s1, const std::size_t _s2, std::uint32_t length);
int compare(const std::size_t _s1, const std::vector<unsigned char>& _s2);

int set(void* _dest, int c, std::size_t length);
int set(std::size_t _dest, int c, std::size_t length);
	
std::vector<unsigned char> nop(void *_dest, std::size_t length);
std::vector<unsigned char> nop(std::size_t _dest, std::size_t length);

void unprotect(std::size_t address, std::size_t size);
void unprotect(const void* address, std::size_t size);

template<std::size_t bits = 8>
constexpr std::size_t
make_mask(std::size_t value) {
	std::size_t result = ~value;
	std::size_t mask_length = 0;
	
    for (std::size_t i = 0; i < sizeof(value) * bits; i++)
		if (value & (0x1 << i)) mask_length = i;

	for (std::size_t i = mask_length + 1; i < sizeof(result) * bits; i++)
        result = (result ^ (1 << i));

	return static_cast<std::size_t>(-1) ^ result;
}

template<std::size_t length>
void*
copy(void* dest, const std::array<unsigned char, length>& src) {
	return copy(dest, reinterpret_cast<void*>(src.data()), src.size());
}

template<std::size_t length>
void*
copy(std::size_t dest, const std::array<unsigned char, length>& src ) {
	return copy(reinterpret_cast<void*>(dest), reinterpret_cast<void*>(src.data()), src.size());
}

template<std::size_t length>
int
compare(const void* _s1, const std::array<unsigned char, length>& _s2) {
	return compare(_s1, reinterpret_cast<void*>(_s2.data()), _s2.size());
}


template<std::size_t length>
int
compare(const std::size_t _s1, const std::array<unsigned char, length>& _s2) {
    return compare(reinterpret_cast<void*>(_s1), reinterpret_cast<void*>(_s2.data()), _s2.size());
}

template<std::size_t length>
std::array<unsigned char, length>
nop(void* _dest) {
	std::array<unsigned char, length> result;
	
    copy(result.data(), _dest, length);
	set(_dest, 0x90, length);
	
    return result;
}

template<std::size_t length>
std::array<unsigned char, length> nop(std::size_t _dest) {
    return nop<length>(reinterpret_cast<void*>(_dest));
}

template<typename T>
void
write(void* address, T value) {
	std::size_t length = sizeof(T);
	DWORD old_vp;

	VirtualProtect(reinterpret_cast<void*>(address), length, PAGE_EXECUTE_READWRITE, &old_vp);
		
    *reinterpret_cast<T*>(address) = value;

	VirtualProtect(reinterpret_cast<void*>(address), length, old_vp, &old_vp);
}

template<typename T>
void
write(std::size_t address, T value) {
    return write<T>(reinterpret_cast<void*>(address), value);
}

template<typename T>
T
read(void* address) {
	std::size_t length = sizeof(T);
	DWORD old_vp;

	VirtualProtect(reinterpret_cast<void*>(address), length, PAGE_EXECUTE_READWRITE, &old_vp);
	
    T value = *reinterpret_cast<T*>(address);
	
    VirtualProtect(reinterpret_cast<void*>(address), length, old_vp, &old_vp);

	return value;
}

template<typename T>
T
read(std::size_t address) {
    return read<T>(reinterpret_cast<void*>(address));
}

} // namespace plugin::memory

#endif // GADMIN_PLUGIN_MEMORY_H
