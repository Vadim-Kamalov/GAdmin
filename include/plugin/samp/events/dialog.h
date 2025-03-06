#ifndef GADMIN_PLUGIN_SAMP_EVENTS_DIALOG_H
#define GADMIN_PLUGIN_SAMP_EVENTS_DIALOG_H

#include "plugin/samp/core/dialog.h"
#include "plugin/samp/events/event.h"
#include <utility>

namespace plugin::samp {

template<>
struct event<event_id::show_dialog> {
    std::uint16_t id;
    dialog::style style;
    std::string title, text;
    std::pair<std::string, std::string> buttons;

    inline bool is_available() const;
    inline explicit operator bool() const;

    void send_response(const dialog::button& button, std::uint16_t list_item = dialog::list_item_none,
                       const std::string_view& input = "") const;

    explicit event(bit_stream* stream);
}; // struct event<event_id::show_dialog>

} // namespace plugin::samp

inline bool
plugin::samp::event<plugin::samp::event_id::show_dialog>::is_available() const {
    return id != dialog::invalid_id;
}

inline plugin::samp::event<plugin::samp::event_id::show_dialog>::operator bool() const {
    return is_available();
}

#endif // GADMIN_PLUGIN_SAMP_EVENTS_DIALOG_H
