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

#include "plugin/gui/notify.h"

auto plugin::gui::notification::with_duration(std::chrono::milliseconds new_duration) -> notification& {
    duration = new_duration;
    return *this;
}

auto plugin::gui::notification::with_buttons(const button& first, const button& second) -> notification& {
    buttons = std::make_pair(first, second);
    return *this;
}

auto plugin::gui::notification::with_condition(condition_t new_condition) -> notification& {
    condition = new_condition;
    return *this;
}

auto plugin::gui::notification::remove() -> void {
    condition = []{ return false; };
}

auto plugin::gui::notify::get_notifications() noexcept -> std::list<notification>& {
    return notifications;
}

auto plugin::gui::notify::has_notifications() noexcept -> bool {
    return !notifications.empty();
}

auto plugin::gui::notify::notifications_count() noexcept -> std::size_t {
    return notifications.size();
}

auto plugin::gui::notify::send(const notification& to_send) -> void {
    notification new_notification(to_send);
    if (on_send_callback(new_notification))
        notifications.push_back(std::move(new_notification));
}

auto plugin::gui::notify::set_callback(callback_t callback) noexcept -> void {
    on_send_callback = callback;
}
