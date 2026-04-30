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

#ifndef GADMIN_PLUGIN_LOG_H
#define GADMIN_PLUGIN_LOG_H

#include "plugin/types/simple.h"
#include <cstdint>
#include <filesystem>
#include <functional>
#include <format>
#include <string>
#include <mutex>
#include <fstream>
#include <utility>

namespace plugin {

/// Log message severity levels.
///
/// @see std::formatter<plugin::message_severity>
enum class message_severity : std::uint8_t {
    info,       ///< Informational message.
    warning,    ///< Warning message.
    error,      ///< Error message
    fatal_error ///< Fatal error message (unloads plugin when received).
}; // enum class message_severity : std::uint8_t

/// Represents a handler that processes and forwards each log message in the file.
class log_handler final {
private:
    std::mutex log_mutex;
    std::ofstream log_file_stream;

    auto get_full_iso_8601_timestamp() const -> std::string;
    auto write_callback(const std::string_view& text, const message_severity& severity) -> void;
public:
    /// Start the log handler with the selected file to output all log messages in.
    ///
    /// @param path[in] Path to the file which will contain all log messages.
    auto load_file(const std::filesystem::path& path) -> void;
}; // class log_handler final

/// Represents logging functionality with different severity levels.
class log final {
public:
    /// Write callback that will receive any messages from the `log::{info,warn,error,fatal}` functions.
    using write_callback_t = std::function<void(const std::string_view& text,
                                                const message_severity& severity)>;

    /// Unload callback that will be called when `log::fatal` function is executed.
    using unload_callback_t = std::function<void()>;
private:
    static inline write_callback_t write_callback = [](const auto&, const auto&) {};
    static inline unload_callback_t unload_callback = [] {};
public:
    /// Set write callback.
    ///
    /// @param new_write_callback[in] New write callback to set.
    static inline auto set_write_callback(write_callback_t new_write_callback) noexcept -> void;
    
    /// Set unload callback.
    ///
    /// @param new_unload_callback[in] New unload callback to set.
    static inline auto set_unload_callback(unload_callback_t new_unload_callback) noexcept -> void;

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

    /// Log fatal error message and unload (free) the plugin.
    ///
    /// @tparam Args    Types of format arguments.
    /// @param fmt[in]  Format string.
    /// @param args[in] Format arguments.
    template<typename... Args>
    static auto fatal(std::format_string<Args...> fmt, Args&&... args) noexcept -> void;
}; // class log final

} // namespace plugin

template<>
struct std::formatter<plugin::message_severity> : std::formatter<std::string_view> {
    auto format(const plugin::message_severity& severity, std::format_context& ctx) const {
        static constexpr plugin::types::zstring_t names[] = {
            "INFO",  ///< plugin::message_severity::info
            "WARN",  ///< plugin::message_severity::warning
            "ERROR", ///< plugin::message_severity::error
            "FATAL"  ///< plugin::message_severity::fatal_error
        }; // static constexpr plugin::types::zstring_t names[]

        return std::formatter<std::string_view>::format(names[std::to_underlying(severity)], ctx);
    }
}; // struct std::formatter<plugin::message_severity> : std::formatter<std::string_view>

inline auto plugin::log::set_write_callback(write_callback_t new_write_callback) noexcept -> void {
    write_callback = std::move(new_write_callback);
}

inline auto plugin::log::set_unload_callback(unload_callback_t new_unload_callback) noexcept -> void {
    unload_callback = std::move(new_unload_callback);
}

template<typename... Args>
inline auto plugin::log::info(std::format_string<Args...> fmt, Args&&... args) noexcept -> void {
    write_callback(std::format(fmt, std::forward<Args>(args)...), message_severity::info);
}

template<typename... Args>
inline auto plugin::log::warn(std::format_string<Args...> fmt, Args&&... args) noexcept -> void {
    write_callback(std::format(fmt, std::forward<Args>(args)...), message_severity::warning);
}

template<typename... Args>
inline auto plugin::log::error(std::format_string<Args...> fmt, Args&&... args) noexcept -> void {
    write_callback(std::format(fmt, std::forward<Args>(args)...), message_severity::error);
}

template<typename... Args>
inline auto plugin::log::fatal(std::format_string<Args...> fmt, Args&&... args) noexcept -> void {
    write_callback(std::format(fmt, std::forward<Args>(args)...), message_severity::fatal_error);
    unload_callback();
}

#endif // GADMIN_PLUGIN_LOG_H
