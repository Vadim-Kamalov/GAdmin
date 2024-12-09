#include "plugin/samp/core/chat.h"

std::uintptr_t
plugin::samp::chat::instance() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x21A0E4, 0x26E8C8, 0x26EB80, 0x2ACA10 };
    return *reinterpret_cast<std::uintptr_t*>(base(offsets[std::to_underlying(get_version())]));
}

plugin::samp::ServerMessage::ServerMessage(samp::BitStream* bit_stream) {
    color = bit_stream->read<std::int32_t>();
    text = encoding::to_utf8(bit_stream->read_string<std::int32_t>());
}
