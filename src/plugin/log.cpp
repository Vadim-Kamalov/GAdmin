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

#include "plugin/log.h"
#include <libloaderapi.h>
#include <windows.h>
#include <chrono>

extern "C" IMAGE_DOS_HEADER __ImageBase;

auto plugin::log_handler::load_file(const std::filesystem::path& path) -> void {
    using namespace std::placeholders;

    // Unfortunately, we can't open the log file stream immediately with both
    // appending and truncate modes (e.g., `std::ios::trunc | std::ios::app`).
    //
    // We can combine these modes using the pipe operator, but it will have no effect.
    std::ofstream(path, std::ios::trunc).close();
    log_file_stream.open(path, std::ios::app);
    log::set_write_callback(std::bind(&log_handler::write_callback, this, _1, _2));
}

auto plugin::log_handler::write_callback(const std::string_view& text, const message_severity& severity) -> void {
    std::lock_guard<std::mutex> lock(log_mutex);
    log_file_stream << std::format("{} [{}] {}\n", get_full_iso_8601_timestamp(), severity, text);
    log_file_stream.flush();
}

auto plugin::log_handler::get_full_iso_8601_timestamp() const -> std::string {
    auto now = std::chrono::system_clock::now();

    std::time_t now_time_t = std::chrono::system_clock::to_time_t(now);
    std::time_t local_time = std::mktime(std::localtime(&now_time_t));
    std::time_t gmt_time = std::mktime(std::gmtime(&now_time_t));

    auto formattable_time = std::chrono::system_clock::from_time_t(local_time);
    int hours_offset = (std::difftime(local_time, gmt_time)) / 3600;

    auto duration = now.time_since_epoch();
    auto seconds = std::chrono::duration_cast<std::chrono::seconds>(duration);
    auto nanoseconds = std::chrono::duration_cast<std::chrono::nanoseconds>(duration - seconds);

    return std::format("{:%FT%T}.{:09}{}{:02}:00", std::chrono::time_point_cast<std::chrono::seconds>(formattable_time),
                       nanoseconds.count(), (hours_offset >= 0) ? '+' : '-', std::abs(hours_offset));
}
