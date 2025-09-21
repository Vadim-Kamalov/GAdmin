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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_MISC_FEATURES_NICKNAME_COLORS_H
#define GADMIN_PLUGIN_MISC_FEATURES_NICKNAME_COLORS_H

#include "plugin/samp/events/server_message.h"
#include "plugin/misc/base/feature.h"
#include "plugin/types/color.h"
#include <nlohmann/json.hpp>
#include <deque>
#include <thread>
#include <vector>
#include <chrono>

namespace plugin::misc {
namespace features {

/// Represents a feature that highlights nicknames of the Sponsors and the Contributors
/// in the `/a` chat. Nicknames are stored in the `$ROOT/nickname-colors.json` and
/// automatically fetched each 5 minutes.
///
/// Only works if a feature is enabled and user is on the `/alogin`.
class nickname_colors final : public feature {
public:
    struct entry_t final {
        std::string nickname;
        std::vector<types::color> colors;
    }; // struct entry_t final
    
    static inline std::deque<entry_t> entries;
private:
    std::jthread downloader_thread;
    std::chrono::steady_clock::time_point time_updated_nickname_colors;

    auto write_nickname_colors() -> void;
    auto on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool;
    auto append_entries(nlohmann::json& object) -> void;
public:
    auto on_event(const samp::event_info& event) -> bool override;
    auto main_loop() -> void override;

    explicit nickname_colors();
}; // class nickname_colors final : public feature

} // namespace features

/// Get colors of the Sponsors and the Contributors nicknames.
/// 
/// @return Colors for certain nicknames.
auto get_nickname_colors() noexcept -> std::deque<features::nickname_colors::entry_t>&;

} // namespace plugin::misc

#endif // GADMIN_PLUGIN_MISC_FEATURES_NICKNAME_COLORS_H
