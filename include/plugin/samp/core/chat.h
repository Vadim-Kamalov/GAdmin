#ifndef GADMIN_PLUGIN_SAMP_CORE_CHAT_H
#define GADMIN_PLUGIN_SAMP_CORE_CHAT_H

#include "plugin/samp/network/bit_stream.h"
#include "plugin/encoding.h"
#include "plugin/samp/samp.h"
#include <format>

namespace plugin {
namespace signatures {

using AddMessage = void(__thiscall*)(std::uintptr_t, unsigned long, const char*);

} // namespace signatures

namespace samp {
namespace chat {

std::uintptr_t instance() noexcept;

template<typename... Args>
static void add_message(unsigned long color, std::format_string<Args...> fmt, Args&&... args) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x645A0, 0x679F0, 0x68170, 0x67BE0 };
    reinterpret_cast<signatures::AddMessage>(base(offsets[std::to_underlying(get_version())]))
        (instance(), color, encoding::to_cp1251(std::format(fmt, std::forward<Args>(args)...)).c_str());
}

} // namespace chat

class ServerMessage {
public:
    static constexpr std::uint8_t event_id = 93;

    std::int32_t color;
    std::string text;

    explicit ServerMessage(samp::BitStream* bit_stream);
}; // class ServerMessage

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_CHAT_H
