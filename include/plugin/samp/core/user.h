#ifndef GADMIN_PLUGIN_SAMP_CORE_USER_H
#define GADMIN_PLUGIN_SAMP_CORE_USER_H

#include <cstdint>
#include <format>
#include <string>
#include "plugin/samp/core/player_pool.h"
#include "plugin/samp/core/input.h"
#include "plugin/samp/samp.h"
#include "plugin/types/simple.h"

namespace plugin {
namespace signatures {

using get_local_player_ping_t = int(__thiscall*)(std::uintptr_t);
using local_player_chat_t = void(__thiscall*)(std::uintptr_t, types::zstring_t);

} // namespace signatures

namespace samp::user {

std::uint16_t get_id() noexcept;
std::string get_name() noexcept;
int get_ping() noexcept;

template<typename... Args>
void chat(std::format_string<Args...> fmt, Args&&... args) noexcept;

template<typename... Args>
void
send_message(std::format_string<Args...> fmt, Args&&... args) noexcept;

} // namespace samp::user
} // namespace plugin

template<typename... Args>
void
plugin::samp::user::chat(std::format_string<Args...> fmt, Args&&... args) noexcept {
    static constexpr std::uintptr_t local_player_offsets[] = { 0x0, 0x0, 0x22, 0x2F3A, 0x26, 0x1E };
    static constexpr std::uintptr_t local_player_chat_offsets[] = { 0x0, 0x0, 0x57F0, 0x5820, 0x5A10, 0x5860 };

    std::uintptr_t local_player = *reinterpret_cast<std::uintptr_t*>(player_pool::get() + local_player_offsets[std::to_underlying(get_version())]);
    std::string message = std::format(fmt, std::forward<Args>(args)...);

    reinterpret_cast<signatures::local_player_chat_t>(base(local_player_chat_offsets))(local_player, message.c_str());
}

template<typename... Args>
void
plugin::samp::user::send_message(std::format_string<Args...> fmt, Args&&... args) noexcept {
    std::string message = std::format(fmt, std::forward<Args>(args)...);

    if (!message.empty() && message[0] == '/') {
        input::send_command("{}", message);
        return;
    }

    chat("{}", message);
}

#endif // GADMIN_PLUGIN_SAMP_CORE_USER_H
