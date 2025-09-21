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

#include "plugin/memory.h"
#include <cstring>
#include <processthreadsapi.h>
#include <stdexcept>

void*
plugin::memory::copy(void* dest, const void* src, std::size_t length) {
    if (dest == nullptr || src == nullptr || length == 0) return nullptr;

    MEMORY_BASIC_INFORMATION mbi;
    VirtualQuery(dest, &mbi, sizeof(mbi));
    VirtualProtect(mbi.BaseAddress, mbi.RegionSize, PAGE_EXECUTE_READWRITE, &mbi.Protect);

    void* pv_retn = std::memcpy(dest, src, length);
    
    VirtualProtect(mbi.BaseAddress, mbi.RegionSize, mbi.Protect, &mbi.Protect);
    FlushInstructionCache(GetCurrentProcess(), dest, length);
    
    return pv_retn;
}

void*
plugin::memory::copy(void* dest, const std::vector<unsigned char>& src) {
    return copy(dest, src.data(), src.size());
}

void*
plugin::memory::copy(std::size_t dest, const std::size_t src, std::size_t length) {
    return copy(reinterpret_cast<void*>(dest), reinterpret_cast<void*>(src), length);
}

void*
plugin::memory::copy(std::size_t dest, const std::vector<unsigned char>& src) {
    return copy(reinterpret_cast<void*>(dest), src);
}

int
plugin::memory::compare(const void* _s1, const void* _s2, std::uint32_t length) {
    const uint8_t* s1 = static_cast<const uint8_t*>(_s1);
    const uint8_t* s2 = static_cast<const uint8_t*>(_s2);
    uint8_t buf[4096];

    for (;;) {
        if (length > 4096) {
            if (!copy(buf, s1, 4096)) return 0;
            if (std::memcmp(buf, s2, 4096)) return 0;
            s1 += 4096;
            s2 += 4096;
            length -= 4096;
        } else {
            if (!copy(buf, s1, length)) return 0;
            if (std::memcmp(buf, s2, length)) return 0;
            break;
        }
    }

    return 1;
}

int
plugin::memory::compare(const void* _s1, const std::vector<unsigned char>& _s2) {
    return compare(_s1, _s2.data(), _s2.size());
}

int
plugin::memory::compare(const std::size_t _s1, const std::size_t _s2, std::uint32_t length) {
    return compare(reinterpret_cast<void*>(_s1), reinterpret_cast<void*>(_s2), length);
}

int
plugin::memory::compare(const std::size_t _s1, const std::vector<unsigned char>& _s2) {
    return compare(reinterpret_cast<void*>(_s1), _s2.data(), _s2.size());
}

int
plugin::memory::set(void* _dest, int c, std::size_t length) {
    std::uint8_t* dest = static_cast<std::uint8_t*>(_dest);
    std::uint8_t buf[4096];
    std::memset(buf, c, (length > 4096) ? 4096 : length);

    for (;;) {
        if (length > 4096) {
            if (!copy(dest, buf, 4096)) return 0;
            dest += 4096;
            length -= 4096;
        } else {
            if (!copy(dest, buf, length)) return 0;
            break;
        }
    }

    return 1;
}

int
plugin::memory::set(std::size_t _dest, int c, std::size_t length) {
    return set(reinterpret_cast<void*>(_dest), c, length);
}

std::vector<unsigned char>
plugin::memory::nop(void* _dest, std::size_t length) {
    std::vector<unsigned char> result(length, 0);
    
    copy(result.data(), _dest, length);
    set(_dest, 0x90, length);

    return result;
}

std::vector<unsigned char>
plugin::memory::nop(std::size_t _dest, std::size_t length) {
    return nop(reinterpret_cast<void*>(_dest), length);
}

void
plugin::memory::unprotect(std::size_t address, std::size_t size) {
    do {
        MEMORY_BASIC_INFORMATION mbi;

        if (!VirtualQuery(reinterpret_cast<void*>(address), &mbi, sizeof(mbi)))
            throw std::runtime_error("virtual query error");

        if (size > mbi.RegionSize)
            size -= mbi.RegionSize;
        else
            size = 0;

        DWORD oldp;

        if (!VirtualProtect(mbi.BaseAddress, mbi.RegionSize, PAGE_EXECUTE_READWRITE, &oldp))
            throw std::runtime_error("virtual protect error");

        if (reinterpret_cast<std::size_t>(mbi.BaseAddress) + mbi.RegionSize < address + size)
            address = reinterpret_cast<std::size_t>(mbi.BaseAddress) + mbi.RegionSize;
    } while (size);
}

void
plugin::memory::unprotect(const void* address, std::size_t size) {
    return unprotect(reinterpret_cast<std::size_t>(address), size);
}
