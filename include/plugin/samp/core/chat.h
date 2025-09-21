/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
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

#ifndef GADMIN_PLUGIN_SAMP_CORE_CHAT_H
#define GADMIN_PLUGIN_SAMP_CORE_CHAT_H

#include "plugin/string_utils.h"
#include "plugin/types/address.h"
#include "plugin/types/color.h"
#include "plugin/types/simple.h"
#include <format>

namespace plugin {
namespace signatures {

using add_message_t = void(__thiscall*)(std::uintptr_t, unsigned long, types::zstring_t);

} // namespace signatures

namespace samp {

/// Provides methods for operating with SA:MP chat window.
class chat final {
private:
    static types::versioned_address_container<signatures::add_message_t> add_message_container;
    static types::versioned_address_container<std::uintptr_t> instance_container;
public:
    /// Add message to the window.
    /// 
    /// @tparam Args     Types of the arguments.
    /// @param color[in] Color of the message.
    /// @param fmt[in]   Format string.
    /// @param args[in]  Arguments to format.
    template<typename... Args>
    static auto add_message(const types::color& color, std::format_string<Args...> fmt, Args&&... args) noexcept -> void;
}; // class chat final

} // namespace samp
} // namespace plugin

template<typename... Args>
auto plugin::samp::chat::add_message(const types::color& color, std::format_string<Args...> fmt, Args&&... args)
    noexcept -> void
{
    add_message_container->invoke(instance_container->read(), color.cast<types::color_type::rgba>(),
                                  string_utils::to_cp1251(std::format(fmt, std::forward<Args>(args)...)).c_str());
}

#endif // GADMIN_PLUGIN_SAMP_CORE_CHAT_H
