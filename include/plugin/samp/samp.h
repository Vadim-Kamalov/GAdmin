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

#ifndef GADMIN_PLUGIN_SAMP_SAMP_H
#define GADMIN_PLUGIN_SAMP_SAMP_H

#include <cstdint>
#include <utility>
#include <format>
#include <windows.h>
#include "plugin/types/simple.h"

namespace plugin::samp {

/// Available SA:MP versions supported by the plugin.
enum class version {
    not_loaded, ///< SA:MP is not loaded.
    unknown,    ///< Unknown SA:MP version.
    v037R1,     ///< SA:MP v0.3.7-R1
    v037R31,    ///< SA:MP v0.3.7-R3-1
    v037R51,    ///< SA:MP v0.3.7-R5-1
    v03DL1,     ///< SA:MP v0.3DL-1
    count       ///< Counts of the values in this enumerator.
}; // enum class version

/// Get `samp.dll` module base address.
///
/// @return Module base address.
auto get_base() noexcept -> std::uintptr_t;

/// Get SA:MP version from the `samp.dll` module.
///
/// @return SA:MP version.
auto get_version() noexcept -> version;

/// Add `offset` to `get_base()` and get the address.
///
/// @param offset[in] Address offset.
/// @return           Summed address of `offset` and `get_base()`.
inline auto base(std::uintptr_t offset) noexcept -> std::uintptr_t;

/// Add `offsets[std::to_underlying(get_version())]` to `get_base()` and get the address.
///
/// @param offsets[in] Addresses on the different SA:MP versions.
/// @return            Summed address of the offset on current SA:MP version  and `get_base()`.
inline auto base(const std::uintptr_t offsets[std::to_underlying(version::count)]) noexcept -> std::uintptr_t;

} // namespace plugin::samp

inline auto plugin::samp::base(std::uintptr_t offset) noexcept -> std::uintptr_t {
    return get_base() + offset;
}

inline auto plugin::samp::base(const std::uintptr_t offsets[std::to_underlying(version::count)]) noexcept -> std::uintptr_t {
    return get_base() + offsets[std::to_underlying(get_version())];
}

template<>
struct std::formatter<plugin::samp::version> : std::formatter<std::string_view> {
    auto format(const plugin::samp::version& version, std::format_context& ctx) const {
        static constexpr plugin::types::zstring_t versions[] = { "not loaded", "unknown", "v0.3.7-R1",
                                                                 "v0.3.7-R3-1", "v0.3.7-R5-1", "v0.3-DL-1" };

        return std::formatter<std::string_view>::format(versions[std::to_underlying(version)], ctx);
    }
}; // struct std::formatter<plugin::samp::version> : std::formatter<std::string_view>

#endif // GADMIN_PLUGIN_SAMP_SAMP_H
