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

#ifndef GADMIN_PLUGIN_SAMP_EVENTS_SYNCHRONIZATION_H
#define GADMIN_PLUGIN_SAMP_EVENTS_SYNCHRONIZATION_H

#include "plugin/samp/events/event.h"
#include "plugin/types/simple.h"
#include <utility>
#include <format>

namespace plugin::samp {

/// Synchronization type.
enum class synchronization_type {
    player,   ///< Player's synchronization.
    vehicle,  ///< Vehicle's synchronization.
    passenger ///< Vehicle Passenger's synchronization.
}; // enum class synchronization_type

/// Synchronization keys.
enum class synchronization_key {
    w, a, s, d, alt, shift, space,
    f, c, rmb, lmb, h, ctrl, q, e,
    up, down, hit, jump_run, aim,
    signal, forward, braking, two,
    backward, count
}; // enum class synchronization_key

/// Names of the synchronization keys.
static constexpr types::zstring_t synchronization_key_names[std::to_underlying(synchronization_key::count)] = {
    "W", "A", "S", "D", "ALT", "SHIFT", "SPACE",
    "F", "C", "RMB", "LMB", "H", "CTRL", "Q",
    "E", "UP", "DOWN", "HIT", "JUMP / RUN", "AIM",
    "SIGNAL", "FORWARD", "BRAKING", "2", "BACKWARD",
}; // static constexpr types::zstring_t synchronization_key_names[std::to_underlying(synchronization_key::count)]

/// Common synchronization information for player, vehicle and passenger.
struct common_synchronization_info {
    std::uint16_t player_id = 0;       ///< Player's ID.
    std::uint16_t left_right_keys = 0; ///< Active Left and Right keys.
    std::uint16_t up_down_keys = 0;    ///< Active Up and Down keys.
    std::uint16_t keys_data = 0;       ///< Active keys. See `synchronization_key`.

    /// Construct common synchronization information.
    ///
    /// @param stream[in]     Bit stream with the event parameters.
    /// @param skip_bytes[in] Amount of bytes needed to skip until this structure fields.
    /// @param check_keys[in] Whether to need check single byte value is true before `left_right_keys` and `up_down_keys` fields.
    explicit common_synchronization_info(bit_stream* stream, int skip_bytes = 0, bool check_keys = false);
}; // struct common_synchronization_info

template<>
struct event<event_id::player_synchronization, event_type::incoming_packet> final : common_synchronization_info {
    explicit event(bit_stream* stream)
        : common_synchronization_info(stream, 0x0, true) {}
}; // struct event<event_id::player_synchronization, event_type::incoming_packet> final : common_synchronization_info

template<>
struct event<event_id::vehicle_synchronization, event_type::incoming_packet> final : common_synchronization_info {
    explicit event(bit_stream* stream)
        : common_synchronization_info(stream, 0x2) {}
}; // struct event<event_id::vehicle_synchronization, event_type::incoming_packet> final : common_synchronization_info

template<>
struct event<event_id::passenger_synchronization, event_type::incoming_packet> final : common_synchronization_info {
    explicit event(bit_stream* stream)
        : common_synchronization_info(stream, 0x6) {}
}; // struct event<event_id::passenger_synchronization, event_type::incoming_packet> final : common_synchronization_info

template<>
struct event<event_id::bullet_synchronization, event_type::incoming_packet> final {
    std::uint16_t player_id; ///< Player's ID.
    std::uint8_t hit_type;   ///< Bullet's hit type.
    std::uint16_t hit_id;    ///< Bullet's hit of player's ID if present.
    types::vector_3d origin; ///< Bullet's start coordinates.
    types::vector_3d hit;    ///< Bullet's end coordinates.
    types::vector_3d offset; ///< Bullet's offset coordinates.
    std::uint8_t weapon_id;  ///< Weapon's ID from which the bullet was fired.

    /// Construct an event.
    ///
    /// @param bit_stream[in] Bit stream with the event parameters.
    explicit event(bit_stream* stream);
}; // struct event<event_id::bullet_synchronization, event_type::incoming_packet> final

} // namespace plugin::samp

template<>
struct std::formatter<plugin::samp::synchronization_key> : std::formatter<std::string_view> {
    auto format(const plugin::samp::synchronization_key& key, std::format_context& ctx) const {
        return std::formatter<std::string_view>::format(plugin::samp::synchronization_key_names[std::to_underlying(key)], ctx);
    }
}; // struct std::formatter<plugin::samp::synchronization_key> : std::formatter<std::string_view>

#endif // GADMIN_PLUGIN_SAMP_EVENTS_SYNCHRONIZATION_H
