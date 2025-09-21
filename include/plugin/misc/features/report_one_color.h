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

#ifndef GADMIN_PLUGIN_MISC_FEATURES_REPORT_ONE_COLOR_H
#define GADMIN_PLUGIN_MISC_FEATURES_REPORT_ONE_COLOR_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/server_message.h"

namespace plugin::misc::features {

/// Represents a feature that changes color of each
/// report message to the one that set by the user.
/// 
/// Only works if a feature is enabled and user is
/// on the `/alogin`.
class report_one_color final : public feature {
private:
    bool change_next_message_color = false;
    auto on_server_message(const samp::event<samp::event_id::server_message>& event) -> bool;
public:
    auto on_event(const samp::event_info& event) -> bool override;
}; // class report_one_color final : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_REPORT_ONE_COLOR_H
