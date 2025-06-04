#ifndef GADMIN_PLUGIN_SAMP_CORE_USER_H
#define GADMIN_PLUGIN_SAMP_CORE_USER_H

#include <cstdint>
#include <format>
#include <string>
#include "plugin/samp/core/input.h"
#include "plugin/string_utils.h"
#include "plugin/types/address.h"
#include "plugin/types/color.h"
#include "plugin/types/simple.h"

namespace plugin {
namespace signatures {

using get_local_player_ping_t = int(__thiscall*)(std::uintptr_t);
using local_player_chat_t = void(__thiscall*)(std::uintptr_t, types::zstring_t);
using get_local_player_color_as_argb = std::uint32_t(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

class user final {
private:
    static types::versioned_address_container<std::uintptr_t, types::version_container_option::offsets> local_player_offsets;
    static types::versioned_address_container<types::zstring_t, types::version_container_option::offsets> name_offsets;
    static types::versioned_address_container<std::uint16_t, types::version_container_option::offsets> id_offsets;
    static types::versioned_address_container<signatures::local_player_chat_t> local_player_chat_container;
    static types::versioned_address_container<signatures::get_local_player_ping_t> get_local_player_ping_container;
    static types::versioned_address_container<signatures::get_local_player_color_as_argb> get_local_player_color_container;
    static auto get_local_player() noexcept -> std::uintptr_t;
public:
    static auto get_color() noexcept -> types::color;
    static auto get_id() noexcept -> std::uint16_t;
    static auto get_name() noexcept -> std::string;
    static auto get_ping() noexcept -> int;

    template<typename... Args>
    static auto chat(std::format_string<Args...> fmt, Args&&... args) noexcept -> void;

    template<typename... Args>
    static auto send_message(std::format_string<Args...> fmt, Args&&... args) noexcept -> void;
}; // class user final

} // namespace samp
} // namespace plugin

template<typename... Args>
auto plugin::samp::user::chat(std::format_string<Args...> fmt, Args&&... args) noexcept -> void {
    local_player_chat_container->invoke(get_local_player(), string_utils::to_cp1251(
        std::format(fmt, std::forward<Args>(args)...)).c_str());
}

template<typename... Args>
auto plugin::samp::user::send_message(std::format_string<Args...> fmt, Args&&... args) noexcept -> void{
    std::string message = std::format(fmt, std::forward<Args>(args)...);

    if (!message.empty() && message[0] == '/') {
        input::send_command("{}", message);
        return;
    }

    chat("{}", message);
}

#endif // GADMIN_PLUGIN_SAMP_CORE_USER_H
