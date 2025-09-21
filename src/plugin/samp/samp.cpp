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

#include "plugin/samp/samp.h"

auto plugin::samp::get_base() noexcept -> std::uintptr_t {
    static std::uintptr_t samp_base = std::to_underlying(version::not_loaded);

    if (samp_base == std::to_underlying(version::not_loaded))
        samp_base = reinterpret_cast<std::uintptr_t>(GetModuleHandleA("samp.dll"));

    return samp_base;
}

auto plugin::samp::get_version() noexcept -> version {
    static version version = version::not_loaded;

    if (version <= version::unknown) {
        std::uintptr_t base = get_base();
        
        if (base == std::to_underlying(version::not_loaded))
            return version::not_loaded;

        auto* nt_header = reinterpret_cast<IMAGE_NT_HEADERS*>(base + reinterpret_cast<IMAGE_DOS_HEADER*>(base)->e_lfanew);
        
        switch (nt_header->OptionalHeader.AddressOfEntryPoint) {
            case 0x31DF13:
                version = version::v037R1;
                break;
            case 0xCC4D0:
                version = version::v037R31;
                break;
            case 0xCBC90:
                version = version::v037R51;
                break;
            case 0xFDB60:
                version = version::v03DL1;
                break;
            default:
                version = version::unknown;
                break;
        }
    }

    return version;
}
