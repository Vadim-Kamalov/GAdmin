#ifndef GADMIN_PLUGIN_SAMP_CORE_USER_H
#define GADMIN_PLUGIN_SAMP_CORE_USER_H

#include <cstdint>
#include <format>
#include <string>
#include "plugin/samp/core/player_pool.h"
#include "plugin/samp/core/input.h"
#include "plugin/types/address.h"
#include "plugin/types/simple.h"

namespace plugin {
namespace signatures {

using get_local_player_ping_t = int(__thiscall*)(std::uintptr_t);
using local_player_chat_t = void(__thiscall*)(std::uintptr_t, types::zstring_t);

} // namespace signatures

namespace samp {

class user {
private:
    static types::versioned_address_container<std::uintptr_t, types::version_container_option::offsets> local_player_offsets;
    static types::versioned_address_container<types::zstring_t, types::version_container_option::offsets> name_offsets;
    static types::versioned_address_container<std::uint16_t, types::version_container_option::offsets> id_offsets;
    static types::versioned_address_container<signatures::local_player_chat_t> local_player_chat_container;
    static types::versioned_address_container<signatures::get_local_player_ping_t> get_local_player_ping_container;
public:
    static std::uint16_t get_id() noexcept;
    static std::string get_name() noexcept;
    static int get_ping() noexcept;

    template<typename... Args>
    static void chat(std::format_string<Args...> fmt, Args&&... args) noexcept;

    template<typename... Args>
    static void send_message(std::format_string<Args...> fmt, Args&&... args) noexcept;
}; // class user

} // namespace samp
} // namespace plugin

template<typename... Args>
void
plugin::samp::user::chat(std::format_string<Args...> fmt, Args&&... args) noexcept {
    local_player_chat_container->invoke(local_player_offsets->read(player_pool::instance()),
                                        std::format(fmt, std::forward<Args>(args)...).c_str());
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
