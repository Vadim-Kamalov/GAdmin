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

#include "plugin/common_utils.h"
#include <chrono>

auto plugin::common_utils::get_current_timestamp() noexcept -> std::string {
    auto now_time_t = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    std::tm tm = *std::localtime(&now_time_t);
    return std::format("[{:02}:{:02}:{:02}]", tm.tm_hour, tm.tm_min, tm.tm_sec);
}
