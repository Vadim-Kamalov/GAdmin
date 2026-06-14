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

#ifndef GADMIN_PLUGIN_MISC_FEATURES_ME_TO_ID_H
#define GADMIN_PLUGIN_MISC_FEATURES_ME_TO_ID_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/send_command.h" // IWYU pragma: keep

namespace plugin::misc::features {

/// Represents a feature that replaces the first command argument `me`
/// with the local player's server ID (e.g. `/aheal me` -> `/aheal 14`).
///
/// Only the first argument after the command name is checked, so the
/// `/me` roleplay command and `me` words inside messages are left intact.
/// Only works if a feature is enabled.
class me_to_id : public feature {
private:
    auto on_send_command(const samp::out_event<samp::event_id::send_command>& event) const -> bool;
public:
    auto on_event(const samp::event_info& event) -> bool override;
}; // class me_to_id : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_ME_TO_ID_H
