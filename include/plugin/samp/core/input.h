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

#ifndef GADMIN_PLUGIN_SAMP_CORE_INPUT_H
#define GADMIN_PLUGIN_SAMP_CORE_INPUT_H

#include "plugin/string_utils.h"
#include "plugin/types/address.h"
#include "plugin/types/simple.h"
#include <format>

namespace plugin {
namespace signatures {

using send_command_t = void(__thiscall*)(std::uintptr_t, types::zstring_t);
using get_text_t = types::zstring_t(__thiscall*)(std::uintptr_t);
using set_text_t = void(__thiscall*)(std::uintptr_t, types::zstring_t, bool);
using open_t = void(__thiscall*)(std::uintptr_t);
using process_input_t = void(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

/// Provides methods for operating with SA:MP input window.
class input final {
public:
    static constexpr std::uint8_t max_commands_count = 144;
    static constexpr std::uint8_t max_command_length = 32;
private:
    static inline types::offset<int> active_offset = 0x14E0;
    static inline types::offset<char(*)[max_command_length + 1]> commands_offset = 0x24C;
    static inline types::offset<std::uintptr_t> dxut_input_offset = 0x8;

    static types::versioned_address_container<std::uintptr_t> instance_container;
    static types::versioned_address_container<signatures::send_command_t> send_command_container;
    static types::versioned_address_container<signatures::open_t> open_container;
    static types::versioned_address_container<signatures::process_input_t> process_input_container;
    static types::versioned_address_container<signatures::set_text_t> set_text_container;
    static types::versioned_address_container<signatures::get_text_t> get_text_container;
public:
    /// Check if the input window is active.
    ///
    /// @return True if the input window is active.
    static auto is_active() noexcept -> bool;

    /// Check if the command is defined in the SA:MP pool.
    ///
    /// @param command[in] Command to check.
    /// @return            True if the command is defined in the SA:MP pool.
    static auto is_command_defined(const std::string_view& command) noexcept -> bool;

    /// Open the window.
    static auto open() noexcept -> void;
    
    /// Send message to the SA:MP chat.
    ///
    /// @note           If you want to send command, use `input::send_command`.
    /// @param text[in] Message to send in the chat.
    static auto process(const std::string_view& text) noexcept -> void;

    /// Set text in the window.
    ///
    /// @param text[in] Text to set.
    static auto set_text(const std::string_view& text) noexcept -> void;

    /// Get text from the window.
    ///
    /// @return Current text in the input window.
    static auto get_text() noexcept -> std::string;

    /// Send command to the SA:MP chat.
    /// 
    /// @tparam Args     Types of the arguments.
    /// @param fmt[in]   Format string.
    /// @param args[in]  Arguments to format.
    template<typename... Args>
    static auto send_command(std::format_string<Args...> fmt, Args&&... args) noexcept -> void;
}; // class input final

} // namespace samp
} // namespace plugin

template<typename... Args>
auto plugin::samp::input::send_command(std::format_string<Args...> fmt, Args&&... args) noexcept -> void {
    send_command_container->invoke(instance_container->read(), string_utils::to_cp1251(
        std::format(fmt, std::forward<Args>(args)...)).c_str());
}

#endif // GADMIN_PLUGIN_SAMP_CORE_INPUT_H
