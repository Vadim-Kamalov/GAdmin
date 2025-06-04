#include "plugin/samp/events/server_message.h"
#include "plugin/string_utils.h"

auto plugin::samp::event<plugin::samp::event_id::server_message>::write(const std::string_view& new_text, const types::color& new_color) const
    -> void
{
    stream->reset_bit_stream();
    stream->write(new_color.cast<types::color_type::rgba>());
    stream->write_string<std::uint32_t>(string_utils::to_cp1251(std::string(new_text)));
}
