#ifndef GADMIN_PLUGIN_SAMP_EVENTS_SYNCHRONIZATION_H
#define GADMIN_PLUGIN_SAMP_EVENTS_SYNCHRONIZATION_H

#include "plugin/samp/events/event.h"
#include "plugin/types/simple.h"
#include <utility>
#include <format>

namespace plugin::samp {

enum class synchronization_type {
    player,
    vehicle,
    passenger
}; // enum class synchronization_type

enum class synchronization_key {
    w, a, s, d, alt, shift, space,
    f, c, rmb, lmb, h, ctrl, q, e,
    up, down, hit, jump_run, aim,
    signal, forward, braking, two,
    backward, count
}; // enum class synchronization_key

static constexpr types::zstring_t synchronization_key_names[std::to_underlying(synchronization_key::count)] = {
    "W", "A", "S", "D", "ALT", "SHIFT", "SPACE",
    "F", "C", "RMB", "LMB", "H", "CTRL", "Q",
    "E", "UP", "DOWN", "HIT", "JUMP / RUN", "AIM",
    "SIGNAL", "FORWARD", "BRAKING", "2", "BACKWARD",
}; // static constexpr types::zstring_t synchronization_key_names[std::to_underlying(synchronization_key::count)]

struct common_synchronization_info {
    std::uint16_t player_id = 0;
    std::uint16_t left_right_keys = 0;
    std::uint16_t up_down_keys = 0;
    std::uint16_t keys_data = 0;

    explicit common_synchronization_info(bit_stream* stream, int skip_bytes = 0, bool check_keys = false);
}; // struct common_synchronization_info

template<>
struct event<event_id::player_synchronization, event_type::incoming_packet> : common_synchronization_info {
    explicit event(bit_stream* stream)
        : common_synchronization_info(stream, 0x0, true) {}
}; // struct event<event_id::player_synchronization, event_type::incoming_packet> : common_synchronization_info

template<>
struct event<event_id::vehicle_synchronization, event_type::incoming_packet> : common_synchronization_info {
    explicit event(bit_stream* stream)
        : common_synchronization_info(stream, 0x2) {}
}; // struct event<event_id::vehicle_synchronization, event_type::incoming_packet> : common_synchronization_info

template<>
struct event<event_id::passenger_synchronization, event_type::incoming_packet> : common_synchronization_info {
    explicit event(bit_stream* stream)
        : common_synchronization_info(stream, 0x6) {}
}; // struct event<event_id::passenger_synchronization, event_type::incoming_packet> : common_synchronization_info

template<>
struct event<event_id::bullet_synchronization, event_type::incoming_packet> {
    std::uint16_t player_id;
    std::uint8_t hit_type;
    std::uint16_t hit_id;
    types::vector_3d origin, hit, offset;
    std::uint8_t weapon_id;

    explicit event(bit_stream* stream);
}; // struct event<event_id::bullet_synchronization, event_type::incoming_packet>

} // namespace plugin::samp

template<>
struct std::formatter<plugin::samp::synchronization_key> : std::formatter<std::string_view> {
    auto format(const plugin::samp::synchronization_key& key, std::format_context& ctx) const {
        return std::formatter<std::string_view>::format(plugin::samp::synchronization_key_names[std::to_underlying(key)], ctx);
    }
}; // struct std::formatter<plugin::samp::synchronization_key> : std::formatter<std::string_view>

#endif // GADMIN_PLUGIN_SAMP_EVENTS_SYNCHRONIZATION_H
