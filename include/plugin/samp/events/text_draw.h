#ifndef GADMIN_PLUGIN_SAMP_EVENTS_TEXT_DRAW_H
#define GADMIN_PLUGIN_SAMP_EVENTS_TEXT_DRAW_H

#include "plugin/samp/events/event.h"

namespace plugin::samp {

template<>
struct event<event_id::show_text_draw> {
    std::uint16_t id;
    std::string text;

    explicit event(bit_stream* stream);
}; // struct event<event_id::show_text_traw>

template<>
struct event<event_id::hide_text_draw> {
    std::uint16_t id;
    explicit event(bit_stream* stream);
}; // struct event<event_id::hide_text_draw>

template<>
struct event<event_id::set_text_draw_string> {
    std::uint16_t id;
    std::string text;

    explicit event(bit_stream* stream);
}; // struct event<event_id::set_text_draw_string>

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_TEXT_DRAW_H
