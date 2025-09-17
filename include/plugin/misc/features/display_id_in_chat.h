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

#ifndef GADMIN_PLUGIN_MISC_FEATURES_DISPLAY_ID_IN_CHAT
#define GADMIN_PLUGIN_MISC_FEATURES_DISPLAY_ID_IN_CHAT

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/server_message.h"

namespace plugin::misc::features {

/// Represents a feature that allows displaying players' ID in the IC chat.
///
/// Only works if a feature is enabled.
class display_id_in_chat final : public feature {
private:
    static auto replace(const std::string& input, const std::string& target, const std::string& replacement) -> std::string;
    auto on_server_message(const samp::event<samp::event_id::server_message>& message) const -> bool;
public:
    auto on_event(const samp::event_info& event) -> bool override;
}; // class display_id_in_chat final : public feature

} // namespace plugin::misc::feature 

#endif // GADMIN_PLUGIN_MISC_FEATURES_DISPLAY_ID_IN_CHAT
