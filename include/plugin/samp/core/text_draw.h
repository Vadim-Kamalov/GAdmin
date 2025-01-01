#ifndef GADMIN_PLUGIN_SAMP_CORE_TEXT_DRAW_H
#define GADMIN_PLUGIN_SAMP_CORE_TEXT_DRAW_H

#include "plugin/samp/network/bit_stream.h"
#include <string>
#include <cstdint>

namespace plugin::samp {

class text_draw {
public:
    static constexpr std::uint8_t event_id = 134;

    std::uint16_t id;
    std::string text;

    explicit text_draw(samp::bit_stream* stream);
}; // class text_draw

class text_draw_string_setter {
public:
    static constexpr std::uint8_t event_id = 105;

    std::uint16_t id;
    std::string text;

    explicit text_draw_string_setter(samp::bit_stream* stream);
}; // class text_draw_string_setter

class text_draw_hider {
public:
    static constexpr std::uint8_t event_id = 135;

    std::uint16_t id;

    explicit text_draw_hider(samp::bit_stream* stream);
}; // class text_draw_hider

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_TEXT_DRAW_H
