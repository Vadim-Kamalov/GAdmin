#include "plugin/samp/core/dialog.h"
#include "plugin/encoding.h"

void
plugin::samp::dialog::send_response(std::uint16_t id, std::uint8_t button_id,
                                    std::uint16_t list_item, const std::string_view& input) noexcept
{
    BitStream bit_stream;
    bit_stream.write(id);
    bit_stream.write(button_id);
    bit_stream.write(list_item);
    bit_stream.write<std::uint8_t>(static_cast<std::uint8_t>(input.size()));
    bit_stream.write(input);
    bit_stream.send_rpc(62);
}

plugin::samp::Dialog::Dialog(BitStream* bit_stream) {
    std::uint16_t dialog_id = bit_stream->read<std::uint16_t>();

    if (dialog_id == 65535) {
        valid = false;
        return;
    }

    id = dialog_id;
    style = bit_stream->read<std::uint8_t>();
    title = encoding::to_utf8(bit_stream->read_string<std::uint8_t>());

    buttons = std::make_pair(encoding::to_utf8(bit_stream->read_string<std::uint8_t>()),
                             encoding::to_utf8(bit_stream->read_string<std::uint8_t>()));
    
    text = encoding::to_utf8(bit_stream->read_encoded(4096));
}
