#include "plugin/samp/core/dialog.h"
#include "plugin/samp/network/bit_stream.h"

plugin::types::versioned_address_container<std::uintptr_t>
plugin::samp::dialog::instance_container = { 0x21A0B8, 0x26E898, 0x26EB50, 0x2AC9E0 };

auto plugin::samp::dialog::send_response(std::uint16_t id, const button& button,
                                         std::uint16_t list_item, const std::string_view& input)
    noexcept -> void
{
    bit_stream stream;
    stream.write(id);
    stream.write(std::to_underlying(button));
    stream.write(list_item);
    stream.write(static_cast<std::uint8_t>(input.size()));
    stream.write(input);
    stream.send_rpc(send_response_id);
}

auto plugin::samp::dialog::is_active() noexcept -> bool {
    return active_address.read(instance_container->read());
}
