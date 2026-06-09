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

#include "common/network.h"
#include <errhandlingapi.h>
#include <windows.h>
#include <wininet.h>
#include <fstream>
#include <functional>
#include <mutex>

namespace {

/// Timeouts on every phase + no retries: a request blocked without VPN fails after
/// `timeout_ms` instead of hanging on WinINet's defaults for tens of seconds.
auto set_timeouts(HINTERNET handle, DWORD timeout_ms) -> void {
    DWORD timeout = timeout_ms;
    DWORD retries = 1;

    InternetSetOption(handle, INTERNET_OPTION_CONNECT_TIMEOUT, &timeout, sizeof(timeout));
    InternetSetOption(handle, INTERNET_OPTION_SEND_TIMEOUT,    &timeout, sizeof(timeout));
    InternetSetOption(handle, INTERNET_OPTION_RECEIVE_TIMEOUT, &timeout, sizeof(timeout));
    InternetSetOption(handle, INTERNET_OPTION_CONNECT_RETRIES, &retries, sizeof(retries));
}

} // namespace

auto common::internet_t::close_handles() noexcept -> void {
    std::scoped_lock lock(handles_mutex);

    if (handles_closed)
        return;

    handles_closed = true;

    if (url)
        InternetCloseHandle(url);

    if (handle)
        InternetCloseHandle(handle);
}

auto common::internet_t::read_file(read_file_callback_t callback) const -> bool {
    char buffer[4096];
    DWORD bytes_read;
    
    while (InternetReadFile(url, buffer, sizeof(buffer), &bytes_read) && bytes_read != 0) {
        if (stop_token.stop_requested())
            return false;

        callback(buffer, bytes_read);
    }

    return true;
}

common::internet_t::internet_t(const std::string_view& link, std::stop_token stop_token)
    : stop_token(stop_token),
      handle(InternetOpen(nullptr, INTERNET_OPEN_TYPE_DIRECT, nullptr, nullptr, 0))
{
    if (!handle) {
        valid = false;
        return;
    }

    set_timeouts(handle, timeout_ms);

    // Closing the session handle from the stop-callback interrupts a blocking InternetOpenUrl/
    // InternetReadFile on request_stop (thread join), without waiting for the timeout.
    stop_cb.emplace(this->stop_token, std::function<void()>([this] { close_handles(); }));

    HINTERNET opened = InternetOpenUrl(handle, std::string(link).c_str(), nullptr, 0, internet_flags, 0);

    std::scoped_lock lock(handles_mutex);

    if (handles_closed) {
        // stop arrived during connect: the session is already closed; close the orphaned URL handle.
        if (opened)
            InternetCloseHandle(opened);

        valid = false;
        return;
    }

    if (opened) {
        url = opened;
        return;
    }

    valid = false;
}

common::internet_t::~internet_t() noexcept {
    // Remove the callback before closing (it captures this); reset() waits for it if it's running.
    stop_cb.reset();
    close_handles();
}

auto common::network::download_file(const std::string_view& url, const std::filesystem::path& output,
                                    std::stop_token stop_token) noexcept -> bool
{
    internet_t internet(url, stop_token); 

    if (!internet)
        return false;

    std::ofstream output_file(output, std::ios::binary);
    
    if (!output_file)
        return false;

    return internet.read_file([&output_file](char buffer[4096], std::size_t bytes_read) {
        output_file.write(buffer, bytes_read);
    });
}

auto common::network::fetch_file_content(const std::string_view& url, std::stop_token stop_token) noexcept -> std::string {
    internet_t internet(url, stop_token);
    std::string content = "";

    if (!internet || !internet.read_file([&content](char buffer[4096], std::size_t bytes_read) {
        content.append(buffer, bytes_read);
    })) return "";

    return content;
}

auto common::network::send_get_request(const std::string_view& url, std::stop_token stop_token) noexcept -> std::string {
    HINTERNET internet = InternetOpen(nullptr, INTERNET_OPEN_TYPE_DIRECT, nullptr, nullptr, 0);

    if (!internet)
        return "";

    // The loader calls this synchronously before loading the plugin: without a timeout a block
    // on api.github.com (no VPN) would delay the plugin load itself.
    set_timeouts(internet, 5000);

    URL_COMPONENTS url_components;
    ZeroMemory(&url_components, sizeof(url_components));
    url_components.dwStructSize = sizeof(url_components);
    url_components.dwSchemeLength = -1;
    url_components.dwHostNameLength = -1;
    url_components.dwUrlPathLength = -1;
    url_components.dwExtraInfoLength = -1;

    // InternetCrackUrl with -1 lengths doesn't copy the string; it points lpszHostName/lpszUrlPath
    // into the buffer, which must outlive the reads below — hence a named, non-temporary string.
    std::string url_string(url);

    if (!InternetCrackUrl(url_string.c_str(), url_string.length(), 0, &url_components)) {
        internet_t::close_handlers(internet);
        return "";
    }

    std::string host_name(url_components.lpszHostName, url_components.dwHostNameLength);
    std::string url_path(url_components.lpszUrlPath, url_components.dwUrlPathLength);

    HINTERNET connect = InternetConnect(internet, host_name.c_str(), url_components.nPort, nullptr, nullptr, INTERNET_SERVICE_HTTP, 0, 0);

    if (!connect) {
        internet_t::close_handlers(internet);
        return "";
    }

    HINTERNET request = HttpOpenRequest(connect, "GET", url_path.c_str(), nullptr, nullptr, nullptr, INTERNET_FLAG_SECURE, 0);

    if (!request) {
        internet_t::close_handlers(connect, internet);
        return "";
    }

    if (!HttpSendRequest(request, headers, strlen(headers), nullptr, 0)) {
        internet_t::close_handlers(request, connect, internet);
        return "";
    }

    std::string content;
    char buffer[4096];
    DWORD bytes_read;

    while (InternetReadFile(request, buffer, sizeof(buffer), &bytes_read) && bytes_read != 0) {
        if (stop_token.stop_requested()) {
            internet_t::close_handlers(request, connect, internet);
            return "";
        }
        
        content.append(buffer, bytes_read);
    }

    internet_t::close_handlers(request, connect, internet);

    return content;
}
