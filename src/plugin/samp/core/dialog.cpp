#include "plugin/samp/core/dialog.h"
#include "plugin/encoding.h"

void
plugin::samp::dialog::send_response(std::uint16_t id, std::uint8_t button_id,
                                    std::uint16_t list_item, const std::string_view& input) noexcept
{
    bit_stream stream;
    stream.write(id);
    stream.write(button_id);
    stream.write(list_item);
    stream.write(static_cast<std::uint8_t>(input.size()));
    stream.write(input);
    stream.send_rpc(62);
}

plugin::samp::dialog::dialog(bit_stream* stream) {
    std::uint16_t dialog_id = stream->read<std::uint16_t>();

    if (dialog_id == 65535) {
        valid = false;
        return;
    }

    id = dialog_id;
    style = stream->read<std::uint8_t>();
    title = encoding::to_utf8(stream->read_string<std::uint8_t>());

    buttons = std::make_pair(encoding::to_utf8(stream->read_string<std::uint8_t>()),
                             encoding::to_utf8(stream->read_string<std::uint8_t>()));
    
    text = encoding::to_utf8(stream->read_encoded(4096));
}
