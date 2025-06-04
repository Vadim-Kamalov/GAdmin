#include "plugin/samp/core/menu.h"
#include "plugin/samp/network/bit_stream.h"

auto plugin::samp::menu::select(std::uint8_t id) noexcept -> void {
    bit_stream stream;
    stream.write(id);
    stream.send_rpc(select_id);
}
