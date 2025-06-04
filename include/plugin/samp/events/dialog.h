#ifndef GADMIN_PLUGIN_SAMP_EVENTS_DIALOG_H
#define GADMIN_PLUGIN_SAMP_EVENTS_DIALOG_H

#include "plugin/samp/core/dialog.h"
#include "plugin/samp/events/event.h"
#include <utility>

namespace plugin::samp {

template<>
class event<event_id::show_dialog> final {
private:
    bit_stream* stream;
public:
    std::uint16_t id;
    dialog::style style;
    std::string title, text;
    std::pair<std::string, std::string> buttons;

    inline auto is_available() const -> bool;
    inline explicit operator bool() const;

    auto send_response(const dialog::button& button, std::uint16_t list_item = dialog::list_item_none,
                       const std::string_view& input = "") const -> void;

    auto write_text(const std::string_view& text) const -> void;

    explicit event(bit_stream* stream);
}; // class event<event_id::show_dialog> final

} // namespace plugin::samp

inline auto plugin::samp::event<plugin::samp::event_id::show_dialog>::is_available() const -> bool {
    return id != dialog::invalid_id;
}

inline plugin::samp::event<plugin::samp::event_id::show_dialog>::operator bool() const {
    return is_available();
}

#endif // GADMIN_PLUGIN_SAMP_EVENTS_DIALOG_H
