#include "plugin/samp/core/dialog.h"
#include "plugin/samp/samp.h"
#include "plugin/encoding.h"

std::uintptr_t
plugin::samp::dialog::instance() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x21A0B8, 0x26E898, 0x26EB50, 0x2AC9E0 };
    return *reinterpret_cast<std::uintptr_t*>(base(offsets));
}

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
    stream.send_rpc(send_response_id);
}

bool
plugin::samp::dialog::is_active() noexcept {
    return *reinterpret_cast<int*>(instance() + 0x50) != 0;
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
