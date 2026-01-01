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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_MISC_FEATURES_AUTO_ALOGOUT_H
#define GADMIN_PLUGIN_MISC_FEATURES_AUTO_ALOGOUT_H

#include "plugin/misc/base/feature.h"
#include <chrono>
#include <cstdint>

using namespace std::chrono_literals;

namespace plugin::misc::features {

/// Represents a feature that allows to run `/alogout` independently from the user
/// while game is not active after certain period of the time: user is notified to
/// return to the game and then if there no response - `/alogout` is sent to the chat.
///
/// Only works if a feature is enabled and user is on the `/alogin`. 
class auto_alogout final : public feature {
private:
    static constexpr std::uint16_t security_icon = 32518;

    bool game_focused = true;
    bool sent_warning_notification = false;
    
    std::chrono::steady_clock::time_point time_updated;
    std::chrono::seconds seconds_inactive = 0s;

    auto send_shell_notification(const std::string& text) const -> void;
    auto set_background_work_state(bool state) const -> void;
public:
    auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool override;
    auto on_alogin_new_state(bool state) -> void override;
    auto main_loop() -> void override;

    ~auto_alogout() noexcept;
}; // class auto_alogout final : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_AUTO_ALOGOUT_H
