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

#ifndef GADMIN_PLUGIN_SAMP_EVENTS_EVENT_H
#define GADMIN_PLUGIN_SAMP_EVENTS_EVENT_H

#include "plugin/samp/network/bit_stream.h"
#include <cstdint>
#include <type_traits>

namespace plugin::samp {

/// Available events (sent to/from the server and later intercepted by
/// the plugin) to catch and to collect data by `samp::event_info`.
enum class event_id : std::uint8_t {
    set_player_name = 11,           ///< Sent when server wants to change any player's name.
    create_3d_text = 36,            ///< Sent when server wants to create 3D text.
    send_command = 50,              ///< Command sent by the user.
    player_death_notification = 55, ///< Sent when server wants to add entry in the kill-list window.
    remove_3d_text = 58,            ///< Sent when server wants to destroy 3D text.
    player_chat_bubble = 59,        ///< Sent when server wants to display any player's chat bubble.
    show_dialog = 61,               ///< Sent when server wants to display dialog to the user.
    show_menu = 77,                 ///< Sent when server wants to show a menu.
    hide_menu = 78,                 ///< Sent when server wants to hide a menu.
    server_message = 93,            ///< Sent when server wants to add entry in the chat window.
    send_chat = 101,                ///< Message sent by the user.
    set_text_draw_string = 105,     ///< Sent when server wants to update any text draw's text.
    spectating_player = 126,        ///< Sent when server wants the user to spectate a player.
    spectating_vehicle = 127,       ///< Sent when server wants the user to spectate a vehicle.
    show_text_draw = 134,           ///< Sent when server wants to display the text draw to the user.
    hide_text_draw = 135,           ///< Sent when server wants to destroy the text draw.
    server_connect = 137,           ///< Sent when server wants to add connected player.
    server_quit = 138,              ///< Sent when server wants to remove disconnected player.
    vehicle_synchronization = 200,  ///< Vehicle's synchronization sent by the user or server.
    bullet_synchronization = 206,   ///< Bullet's ynchronization sent by the user or server.
    player_synchronization = 207,   ///< Player's synchronization sent by the user or server.
    passenger_synchronization = 211 ///< Vehicle Passenger's synchronization sent by the user or server.
}; // enum class event_id : std::uint8_t

/// Event types.
enum class event_type : std::uint8_t {
    incoming_rpc,    ///< RPC sent **to** the user.
    outgoing_rpc,    ///< RPC sent **by** the user.
    incoming_packet, ///< Packet sent **from** the server.
    outgoing_packet  ///< Packet sent **to** the server.
}; // enum class event_type : std::uint8_t

/// Specialization of the events sent to/from the server.
template<event_id, event_type = event_type::incoming_rpc>
struct event {};

/// Helper type for events with incoming packet data.
template<event_id id>
using packet = event<id, event_type::incoming_packet>;

/// Helper type for events with outgoing RPC data.
template<event_id id>
using out_event = event<id, event_type::outgoing_rpc>;

/// Represents an event and its data intercepted from the server or user.
class event_info final {
public:
    bit_stream* stream; ///< Bit Stream with event information.
    event_type type;    ///< Event type.
    std::uint8_t id;    ///< Event ID.

    /// Check the equality of `event_id` paramter and `id` field.
    ///
    /// @note           Equivalent to `std::to_underlying(e_id) == id`..
    /// @param e_id[in] Event ID to compare with.
    /// @return         True if the IDs are equal.
    auto operator==(const event_id& e_id) const -> bool;

    /// Check if the event type is `e_type`.
    ///
    /// @note             Equivalent to `e_type == type`.
    /// @param e_type[in] Event type to compary with.
    /// @return           True if the event types are the same.
    auto operator==(const event_type& e_type) const -> bool;

    /// Collect event parameters and get event's specialization.
    ///
    /// @return Event specialization.
    template<event_id e_id, event_type e_type = event_type::incoming_rpc>
    auto create() const -> event<e_id, e_type>;

    /// Construct an event.
    ///
    /// @param type[in]   Event's type.
    /// @param id[in]     Event's id.
    /// @param stream[in] Event's Bit Stream.
    explicit event_info(const event_type& type, std::uint8_t id, bit_stream* stream)
        : type(type), id(id), stream(stream) {}
}; // class event_info final

} // namespace plugin::samp

template<plugin::samp::event_id e_id, plugin::samp::event_type e_type>
auto plugin::samp::event_info::create() const -> event<e_id, e_type> {
    if constexpr (std::is_empty_v<event<e_id, e_type>>)
        return event<e_id, e_type>();

    static_assert(std::is_constructible_v<event<e_id, e_type>, bit_stream*>);
    
    return event<e_id, e_type>(stream);
}

#endif // GADMIN_PLUGIN_SAMP_EVENTS_EVENT_H
