#ifndef GADMIN_PLUGIN_SAMP_CORE_CHAT_H
#define GADMIN_PLUGIN_SAMP_CORE_CHAT_H

#include "plugin/samp/network/bit_stream.h"
#include "plugin/encoding.h"
#include "plugin/samp/samp.h"
#include <format>

namespace plugin {
namespace signatures {

using add_message_t = void(__thiscall*)(std::uintptr_t, unsigned long, const char*);

} // namespace signatures

namespace samp {
namespace chat {

std::uintptr_t instance() noexcept;

template<typename... Args>
void add_message(unsigned long color, std::format_string<Args...> fmt, Args&&... args) noexcept;

} // namespace chat

class server_message {
public:
    static constexpr std::uint8_t event_id = 93;

    std::int32_t color;
    std::string text;

    explicit server_message(samp::bit_stream* bit_stream);
}; // class server_message

} // namespace samp
} // namespace plugin

template<typename... Args>
void
plugin::samp::chat::add_message(unsigned long color, std::format_string<Args...> fmt, Args&&... args) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x645A0, 0x679F0, 0x68170, 0x67BE0 };
    reinterpret_cast<signatures::add_message_t>(base(offsets))(instance(), color,
        encoding::to_cp1251(std::format(fmt, std::forward<Args>(args)...)).c_str());
}

#endif // GADMIN_PLUGIN_SAMP_CORE_CHAT_H
