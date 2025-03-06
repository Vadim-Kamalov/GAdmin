#include "plugin/samp/events/dialog.h"
#include "plugin/encoding.h"

void
plugin::samp::event<plugin::samp::event_id::show_dialog>::send_response(const dialog::button& button,
                                                                        std::uint16_t list_item,
                                                                        const std::string_view& input) const
{
    dialog::send_response(id, button, list_item, input);
}

plugin::samp::event<plugin::samp::event_id::show_dialog>::event(bit_stream* stream) : id(stream->read<std::uint16_t>()) {
    if (id == dialog::invalid_id)
        return;

    style = static_cast<dialog::style>(stream->read<std::uint8_t>());
    title = encoding::to_utf8(stream->read_string<std::uint8_t>());

    buttons = std::make_pair(encoding::to_utf8(stream->read_string<std::uint8_t>()),
                             encoding::to_utf8(stream->read_string<std::uint8_t>()));

    text = encoding::to_utf8(stream->read_encoded(4096));
}
