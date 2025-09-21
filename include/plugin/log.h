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

#ifndef GADMIN_PLUGIN_LOG_H
#define GADMIN_PLUGIN_LOG_H

#include "plugin/types/simple.h"
#include <functional>
#include <string_view>
#include <format>
#include <utility>

namespace plugin {

/// Provides logging functionality with different severity levels.
///
/// Supports information, warning, error, and fatal log messages.
/// Allows customization of log message handling through callback functions.
class log final {
public:
    /// Log message severity levels.
    enum class type {
        info,  ///< Informational message.
        warn,  ///< Warning message.
        error, ///< Error message.
        fatal  ///< Fatal error message (unloads plugin).
    }; // enum class type

    /// Callback function that accepts all log messages sent during plugin runtime.
    using handler_t = std::function<void(const type&, const std::string_view&)>;
private:
    static inline handler_t handler = [](const type&, const std::string_view&) {};
    static constexpr types::zstring_t types[] = { "INFO", "WARN", "ERROR", "FATAL" };

    static auto get_current_time() noexcept -> std::string;

    template<type message_type>
    static auto write(const std::string_view& text) noexcept -> void;
public:
    /// Set custom log message handler.
    ///
    /// @param new_handler[in] New function to handle log messages.
    static auto set_handler(handler_t new_handler) noexcept -> void;

    /// Log informational message.
    ///
    /// @tparam Args    Types of format arguments.
    /// @param fmt[in]  Format string.
    /// @param args[in] Format arguments.
    template<typename... Args>
    static auto info(std::format_string<Args...> fmt, Args&&... args) noexcept -> void;

    /// Log warning message.
    ///
    /// @tparam Args    Types of format arguments.
    /// @param fmt[in]  Format string.
    /// @param args[in] Format arguments.
    template<typename... Args>
    static auto warn(std::format_string<Args...> fmt, Args&&... args) noexcept -> void;

    /// Log error message.
    ///
    /// @tparam Args    Types of format arguments.
    /// @param fmt[in]  Format string.
    /// @param args[in] Format arguments.
    template<typename... Args>
    static auto error(std::format_string<Args...> fmt, Args&&... args) noexcept -> void;

    /// Log fatal error message and unload the plugin.
    ///
    /// @tparam Args    Types of format arguments.
    /// @param fmt[in]  Format string.
    /// @param args[in] Format arguments.
    template<typename... Args>
    static auto fatal(std::format_string<Args...> fmt, Args&&... args) noexcept -> void;
}; // class log final

} // namespace plugin

template<plugin::log::type message_type>
auto plugin::log::write(const std::string_view& text) noexcept -> void {
    handler(message_type, std::format("{} [{}] {}", get_current_time(),
                                      types[std::to_underlying(message_type)], text));
}

template<typename... Args>
inline auto plugin::log::info(std::format_string<Args...> fmt, Args&&... args) noexcept -> void {
    write<type::info>(std::format(fmt, std::forward<Args>(args)...));
}

template<typename... Args>
inline auto plugin::log::warn(std::format_string<Args...> fmt, Args&&... args) noexcept -> void {
    write<type::warn>(std::format(fmt, std::forward<Args>(args)...));
}

template<typename... Args>
inline auto plugin::log::error(std::format_string<Args...> fmt, Args&&... args) noexcept -> void {
    write<type::error>(std::format(fmt, std::forward<Args>(args)...));
}

template<typename... Args>
inline auto plugin::log::fatal(std::format_string<Args...> fmt, Args&&... args) noexcept -> void {
    write<type::fatal>(std::format(fmt, std::forward<Args>(args)...));
}

#endif // GADMIN_PLUGIN_LOG_H
