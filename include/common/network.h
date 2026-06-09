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

#ifndef GADMIN_COMMON_NETWORK_H
#define GADMIN_COMMON_NETWORK_H

#include <functional>
#include <stop_token>
#include <string_view>
#include <filesystem>
#include <mutex>
#include <optional>
#include <windows.h>
#include <wininet.h>

namespace common {

/// Provides methods for checking connection status and reading files.
/// Ensures WinINet API handles for secure internet connections. Generally,
/// should not be used directly: prefer using methods from `network::*` when
/// dealing with the network operations.
class internet_t final {
private:
    static constexpr DWORD internet_flags =
        INTERNET_FLAG_RELOAD | INTERNET_FLAG_NO_CACHE_WRITE | INTERNET_FLAG_SECURE;

    /// Timeout (ms) for each request phase (connect/send/receive); otherwise a block without VPN
    /// would hang on WinINet's defaults for tens of seconds.
    static constexpr DWORD timeout_ms = 5000;

    bool valid = true;
    std::stop_token stop_token;

    // close_handles() may be called concurrently by the destructor and the stop-callback from
    // different threads — the mutex + flag close the handles exactly once.
    std::mutex handles_mutex;
    bool handles_closed = false;
    std::optional<std::stop_callback<std::function<void()>>> stop_cb;

    /// Close the WinINet handles exactly once (thread-safe). From the stop-callback it closes the
    /// session, interrupting a blocking InternetOpenUrl/InternetReadFile on another thread.
    auto close_handles() noexcept -> void;
public:
    /// Callback function type for reading file data.
    ///
    /// @param buffer[in]     Data buffer containing read bytes.
    /// @param bytes_read[in] Number of bytes read into buffer.
    using read_file_callback_t = std::function<void(char buffer[4096], std::size_t bytes_read)>;

    HINTERNET handle;       ///< WinINet Internet Handle.
    HINTERNET url = nullptr; ///< WinINet URL Handle.
    
    /// Check if internet connection is available.
    ///
    /// @return True if connection is valid.
    inline auto is_available() const -> bool;

    /// Check if internet connection is available. Same as
    /// `internet_t::is_available()`, but as the operator function.
    ///
    /// @return True if connection is valid.
    inline explicit operator bool() const;

    /// Read file content using provided callback.
    ///
    /// @param callback[in] Function to process read data chunks.
    /// @return             True if read operation succeeded.
    auto read_file(read_file_callback_t callback) const -> bool;

    /// Close multiple WinINet handles.
    ///
    /// @tparam Args        Types of handle arguments.
    /// @param handlers[in] WinINet handles to close.
    template<typename... Args>
    static auto close_handlers(Args&&... handlers) noexcept -> void;

    /// Construct internet connection handler.
    ///
    /// @param link[in]       URL to connect to.
    /// @param stop_token[in] Stop token for cancellation.
    explicit internet_t(const std::string_view& link, std::stop_token stop_token);
    
    /// Destroy internet connection handler: closes all open handles and cleans up resources.
    ~internet_t() noexcept;
}; // class internet_t final

/// Provides methods for interaction with the Internet.
class network final {
private:
    static constexpr const char* headers = "User-Agent: GAdmin/1.0\r\n";
public:
    /// Download file from URL to local path.
    ///
    /// @param url[in]        URL to download from.
    /// @param output[in]     Local filesystem path to save file.
    /// @param stop_token[in] Stop token for cancellation (default: empty).
    /// @return               True if download succeeded.
    static auto download_file(const std::string_view& url, const std::filesystem::path& output,
                              std::stop_token stop_token = std::stop_token()) noexcept -> bool;

    /// Fetch file content from URL as string.
    ///
    /// @param url[in]        URL to fetch content from.
    /// @param stop_token[in] Stop token for cancellation (default: empty).
    /// @return               Fetched content as string (empty if failed).
    static auto fetch_file_content(const std::string_view& url,
                                   std::stop_token stop_token = std::stop_token()) noexcept -> std::string;

    /// Send HTTP GET request to URL.
    ///
    /// @param url[in]        URL to send request to.
    /// @param stop_token[in] Stop token for cancellation (default: empty).
    /// @return               Response content as string (empty if failed).
    static auto send_get_request(const std::string_view& url,
                                 std::stop_token stop_token = std::stop_token()) noexcept -> std::string;
}; // class network final

} // namespace common

inline auto common::internet_t::is_available() const -> bool {
    return valid;
}

inline common::internet_t::operator bool() const {
    return is_available();
}

template<typename... Args>
auto common::internet_t::close_handlers(Args&&... handlers) noexcept -> void {
    (InternetCloseHandle(std::forward<Args>(handlers)), ...);
}

#endif // GADMIN_COMMON_NETWORK_H
