#ifndef GADMIN_PLUGIN_SAMP_CORE_SYNCHRONIZATION_H
#define GADMIN_PLUGIN_SAMP_CORE_SYNCHRONIZATION_H

#include "plugin/samp/network/bit_stream.h"
#include "plugin/types/simple.h"
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

enum class synchronization_type { player, vehicle, passenger };

static constexpr types::zstring_t synchronization_key_names[std::to_underlying(synchronization_key::count)] = {
    "W", "A", "S", "D", "ALT", "SHIFT", "SPACE", "F", "C", "RMB", "LMB", "H", "CTRL", "Q", "E", "UP",
    "DOWN", "HIT", "JUMP / RUN", "AIM", "SIGNAL", "FORWARD", "BRAKING", "2", "BACKWARD"
}; // static constexpr types::zstring_t synchronization_key_names[std::to_underlying(synchronization_key::count)]

struct basic_synchronization {
    std::uint16_t player_id = 0;
    std::uint16_t left_right_keys = 0;
    std::uint16_t up_down_keys = 0;
    std::uint16_t keys_data = 0;

    explicit basic_synchronization(samp::bit_stream* stream, int skip_bytes = 0, bool check_keys = false);
}; // struct basic_synchronization

class player_synchronization : public basic_synchronization {
public:
    static constexpr std::uint8_t event_id = 207;
    explicit player_synchronization(samp::bit_stream* stream)
        : basic_synchronization(stream, 0x0, true) {}
}; // class player_synchronization : public basic_synchronization

class vehicle_synchronization : public basic_synchronization {
public:
    static constexpr std::uint8_t event_id = 200;
    explicit vehicle_synchronization(samp::bit_stream* stream)
        : basic_synchronization(stream, 0x2) {}
}; // class vehicle_synchronization : public basic_synchronization

class passenger_synchronization : public basic_synchronization {
public:
    static constexpr std::uint8_t event_id = 211;
    explicit passenger_synchronization(samp::bit_stream* stream)
        : basic_synchronization(stream, 0x6) {}
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

template<>
struct std::formatter<plugin::samp::synchronization_key> : std::formatter<std::string_view> {
    auto format(const plugin::samp::synchronization_key& key, std::format_context& ctx) const {
        return std::formatter<std::string_view>::format(plugin::samp::synchronization_key_names[std::to_underlying(key)], ctx);
    }
}; // struct std::formatter<plugin::samp::synchronization_key> : std::formatter<std::string_view>

#endif // GADMIN_PLUGIN_SAMP_CORE_SYNCHRONIZATION_H
