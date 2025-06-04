#include "plugin/samp/events/send_command.h"

auto plugin::samp::event<plugin::samp::event_id::send_command, plugin::samp::event_type::outgoing_rpc>::write_command(
    const std::string_view& new_command
) const -> void {
    stream->reset_bit_stream();
    stream->write_string<std::uint32_t>(string_utils::to_cp1251(std::string(new_command)));
}
