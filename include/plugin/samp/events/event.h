#ifndef GADMIN_PLUGIN_SAMP_EVENTS_EVENT_H
#define GADMIN_PLUGIN_SAMP_EVENTS_EVENT_H

#include "plugin/samp/network/bit_stream.h"
#include <cstdint>
#include <type_traits>

namespace plugin::samp {

enum class event_id : std::uint8_t {
    create_3d_text = 36,
    player_death_notification = 55,
    remove_3d_text = 58,
    player_chat_bubble = 59,
    show_dialog = 61,
    show_menu = 77,
    server_message = 93,
    set_text_draw_string = 105,
    show_text_draw = 134,
    hide_text_draw = 135,
    vehicle_synchronization = 200,
    bullet_synchronization = 206,
    player_synchronization = 207,
    passenger_synchronization = 211,
}; // enum class event_id : std::uint8_t

enum class event_type : std::uint8_t {
    incoming_rpc,
    outgoing_rpc,
    incoming_packet,
    outgoing_packet
}; // enum class event_type : std::uint8_t

template<event_id, event_type = event_type::incoming_rpc>
struct event {};

template<event_id id>
using packet = event<id, event_type::incoming_packet>;

class event_info {
public:
    bit_stream* stream;
    event_type type;
    std::uint8_t id;

    bool operator==(const event_id& e_id) const;
    bool operator==(const event_type& e_type) const;

    template<event_id e_id, event_type e_type = event_type::incoming_rpc>
    event<e_id, e_type> create() const;

    explicit event_info(const event_type& type, std::uint8_t id, bit_stream* stream)
        : type(type), id(id), stream(stream) {}
}; // class basic_event

} // namespace plugin::samp

template<plugin::samp::event_id e_id, plugin::samp::event_type e_type>
plugin::samp::event<e_id, e_type>
plugin::samp::event_info::create() const {
    if constexpr (std::is_empty_v<event<e_id, e_type>>)
        return event<e_id, e_type>();

    static_assert(std::is_constructible_v<event<e_id, e_type>, bit_stream*>);
    
    return event<e_id, e_type>(stream);
}

#endif // GADMIN_PLUGIN_SAMP_EVENTS_EVENT_H
