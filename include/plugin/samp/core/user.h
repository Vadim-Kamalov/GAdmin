/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2026 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

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

/// Provides methods for getting information and performing actions from the user in the SA:MP client.
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
    /// Get user's clist color.
    ///
    /// @return User's clist color.
    static auto get_color() noexcept -> types::color;
    
    /// Get user's ID.
    ///
    /// @return User's id.
    static auto get_id() noexcept -> std::uint16_t;
    
    /// Get user's nickname.
    ///
    /// @return User's nickname.
    static auto get_name() noexcept -> std::string;
    
    /// Get user's ping.
    ///
    /// @return User's ping.
    static auto get_ping() noexcept -> int;

    /// Emulate sending message in the chat by the user.
    /// 
    /// @note           If you want to emulate sending command from the user, use `user::send_message`.
    /// @tparam Args    Types of the arguments.
    /// @param fmt[in]  Format string.
    /// @param args[in] Arguments to format.
    template<typename... Args>
    static auto chat(std::format_string<Args...> fmt, Args&&... args) noexcept -> void;

    /// Emulate sending message in the chat (with the compatibility for sending commands) by the user.
    ///
    /// @tparam Args    Types of the arguments.
    /// @param fmt[in]  Format string.
    /// @param args[in] Arguments to format.
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
