#ifndef GADMIN_PLUGIN_SAMP_EVENTS_SPECTATING_H
#define GADMIN_PLUGIN_SAMP_EVENTS_SPECTATING_H

#include "plugin/samp/events/event.h"

namespace plugin::samp {

struct basic_spectating_information {
    std::uint16_t id;
    std::uint8_t camera_type;

    explicit basic_spectating_information(bit_stream* stream)
        : id(stream->read<std::uint16_t>()),
          camera_type(stream->read<std::uint8_t>()) {}
}; // struct basic_spectating_information

template<>
struct event<event_id::spectating_player> final : basic_spectating_information {
    using basic_spectating_information::basic_spectating_information;
}; // struct event<event_id::spectating_player> final : basic_spectating_information

template<>
struct event<event_id::spectating_vehicle> final : basic_spectating_information {
    using basic_spectating_information::basic_spectating_information;
}; // struct event<event_id::spectating_vehicle> final : basic_spectating_information

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_SPECTATING_H
