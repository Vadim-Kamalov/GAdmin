#ifndef GADMIN_PLUGIN_SAMP_CORE_SYNCHRONIZATION_H
#define GADMIN_PLUGIN_SAMP_CORE_SYNCHRONIZATION_H

#include "plugin/samp/network/bit_stream.h"
#include <utility>
#include <format>

namespace plugin::samp {

enum class synchronization_key {
    w, a, s, d, alt, shift, space,
    f, c, rmb, lmb, h, ctrl, q, e,
    up, down, hit, jump_run, aim,
    signal, forward, braking, two,
    backward, count
}; // enum class synchronization_key

static constexpr const char* synchronization_key_names[std::to_underlying(synchronization_key::count)] = {
    "W", "A", "S", "D", "ALT", "SHIFT", "SPACE", "F", "C", "RMB", "LMB", "H", "CTRL", "Q", "E", "UP",
    "DOWN", "HIT", "JUMP / RUN", "AIM", "SIGNAL", "FORWARD", "BRAKING", "2", "BACKWARD"
}; // static constexpr const char* synchronization_key_names[std::to_underlying(synchronization_key::count)]

template<int skip_bytes = 0, bool check_keys = false>
struct basic_synchronization {
    std::uint16_t player_id = 0;
    std::uint16_t left_right_keys = 0;
    std::uint16_t up_down_keys = 0;
    std::uint16_t keys_data = 0;
    explicit basic_synchronization(samp::bit_stream* stream);
}; // struct basic_synchronization

class player_synchronization : public basic_synchronization<0, true> {
public:
    static constexpr std::uint8_t event_id = 207;
    using basic_synchronization::basic_synchronization;
}; // class player_synchronization : public basic_synchronization<>

class vehicle_synchronization : public basic_synchronization<0x2> {
public:
    static constexpr std::uint8_t event_id = 200;
    using basic_synchronization::basic_synchronization;
}; // class vehicle_synchronization : public basic_synchronization

class passenger_synchronization : public basic_synchronization<0x6> {
public:
    static constexpr std::uint8_t event_id = 211;
    using basic_synchronization::basic_synchronization;
}; // class passenger_synchronization : public basic_synchronization

class bullet_synchronization {
public:
    static constexpr std::uint8_t event_id = 206;

    std::uint16_t player_id;
    std::uint8_t hit_type;
    std::uint16_t hit_id;
    float origin_x, origin_y, origin_z;
    float hit_pos_x, hit_pos_y, hit_pos_z;
    float offset_x, offset_y, offset_z;
    std::uint8_t weapon_id;

    explicit bullet_synchronization(samp::bit_stream* stream);
}; // class bullet_synchronization

} // namespace plugin::samp

template<int skip_bytes, bool check_keys>
plugin::samp::basic_synchronization<skip_bytes, check_keys>::basic_synchronization(samp::bit_stream* stream) {
    stream->ignore_bytes(0x1);

    player_id = stream->read<std::uint16_t>();

    if constexpr (skip_bytes != 0)
        stream->ignore_bytes(skip_bytes);

    if constexpr (check_keys) {
        if (stream->read<bool>())
            left_right_keys = stream->read<std::uint16_t>();

        if (stream->read<bool>())
            up_down_keys = stream->read<std::uint16_t>();
    } else {
        left_right_keys = stream->read<std::uint16_t>();
        up_down_keys = stream->read<std::uint16_t>();
    }

    keys_data = stream->read<std::uint16_t>();
}

template<>
struct std::formatter<plugin::samp::synchronization_key> : std::formatter<std::string_view> {
    auto format(const plugin::samp::synchronization_key& key, std::format_context& ctx) const {
        return std::formatter<std::string_view>::format(plugin::samp::synchronization_key_names[std::to_underlying(key)], ctx);
    }
}; // struct std::formatter<plugin::samp::version> : std::formatter<std::string_view>

#endif // GADMIN_PLUGIN_SAMP_CORE_SYNCHRONIZATION_H
