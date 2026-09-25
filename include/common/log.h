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

#ifndef GADMIN_COMMON_LOG_H
#define GADMIN_COMMON_LOG_H

#include <cstdint>
#include <filesystem>
#include <functional>
#include <format>
#include <string>
#include <mutex>
#include <fstream>
#include <utility>

namespace common {

/// Log message severity levels.
///
/// @see std::formatter<common::message_severity>
enum class message_severity : std::uint8_t {
    info,       ///< Informational message.
    warning,    ///< Warning message.
    error,      ///< Error message
    fatal_error ///< Fatal error message (unloads common when received).
}; // enum class message_severity : std::uint8_t

/// Represents a handler that processes and forwards each log message in the file.
class log_handler final {
private:
    std::mutex log_mutex;
    std::ofstream log_file_stream;
    std::string prefix = "unknown";

    auto get_full_iso_8601_timestamp() const -> std::string;
    auto write_callback(const std::string_view& text, const message_severity& severity) -> void;
public:
    /// Set prefix which will be prepended to all log messages.
    ///
    /// @param prefix[in] New prefix to set.
    auto set_prefix(const std::string_view new_prefix) -> void;
    
    /// Start the log handler with the selected file to output all log messages in.
    ///
    /// @param path[in]          Path to the file which will contain all log messages.
    /// @param truncate_file[in] Whether to truncate the file before opening it.
    auto load_file(const std::filesystem::path& path, bool truncate_file) -> void;

    /// Close the file which was loaded previously by the `load_file` method.
    auto close_file() -> void;
}; // class log_handler final

} // namespace common

/// Represents logging functionality with different severity levels.
class log final {
public:
    /// Write callback that will receive any messages from the `log::{info,warn,error,fatal}` functions.
    using write_callback_t = std::function<void(const std::string_view& text,
                                                const common::message_severity& severity)>;

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

    /// Log fatal error message without unloading the common.
    ///
    /// @tparam Args    Types of format arguments.
    /// @param fmt[in]  Format string.
    /// @param args[in] Format arguments.
    template<typename... Args>
    static auto fatal_without_unload(std::format_string<Args...> fmt, Args&&... args) noexcept -> void;

    /// Log fatal error message and unload (free) the common.
    ///
    /// @tparam Args    Types of format arguments.
    /// @param fmt[in]  Format string.
    /// @param args[in] Format arguments.
    template<typename... Args>
    static auto fatal(std::format_string<Args...> fmt, Args&&... args) noexcept -> void;
}; // class log final

template<>
struct std::formatter<common::message_severity> : std::formatter<std::string_view> {
    auto format(const common::message_severity& severity, std::format_context& ctx) const {
        static constexpr const char* names[] = {
            "INFO",  ///< common::message_severity::info
            "WARN",  ///< common::message_severity::warning
            "ERROR", ///< common::message_severity::error
            "FATAL"  ///< common::message_severity::fatal_error
        }; // static constexpr const char* names[]

        return std::formatter<std::string_view>::format(names[std::to_underlying(severity)], ctx);
    }
}; // struct std::formatter<common::message_severity> : std::formatter<std::string_view>

inline auto log::set_write_callback(write_callback_t new_write_callback) noexcept -> void {
    write_callback = std::move(new_write_callback);
}

inline auto log::set_unload_callback(unload_callback_t new_unload_callback) noexcept -> void {
    unload_callback = std::move(new_unload_callback);
}

template<typename... Args>
inline auto log::info(std::format_string<Args...> fmt, Args&&... args) noexcept -> void {
    write_callback(std::format(fmt, std::forward<Args>(args)...), common::message_severity::info);
}

template<typename... Args>
inline auto log::warn(std::format_string<Args...> fmt, Args&&... args) noexcept -> void {
    write_callback(std::format(fmt, std::forward<Args>(args)...), common::message_severity::warning);
}

template<typename... Args>
inline auto log::error(std::format_string<Args...> fmt, Args&&... args) noexcept -> void {
    write_callback(std::format(fmt, std::forward<Args>(args)...), common::message_severity::error);
}

template<typename... Args>
inline auto log::fatal_without_unload(std::format_string<Args...> fmt, Args&&... args) noexcept -> void {
    write_callback(std::format(fmt, std::forward<Args>(args)...), common::message_severity::fatal_error);
}

template<typename... Args>
inline auto log::fatal(std::format_string<Args...> fmt, Args&&... args) noexcept -> void {
    write_callback(std::format(fmt, std::forward<Args>(args)...), common::message_severity::fatal_error);
    unload_callback();
}

#endif // GADMIN_COMMON_LOG_H
