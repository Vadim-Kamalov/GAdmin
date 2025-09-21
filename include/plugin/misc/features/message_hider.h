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

#ifndef GADMIN_PLUGIN_MISC_FEATURES_MESSAGE_HIDER_H
#define GADMIN_PLUGIN_MISC_FEATURES_MESSAGE_HIDER_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/server_message.h"
#include "plugin/types/color.h"
#include <unordered_map>
#include <variant>

namespace plugin::misc::features {

/// Represents a feature that allows to hide certain messages:
///
///     - AntiCheat's messages;
///     - Punishments' messages;
///     - Players Actions's messages;
///     - Complaint messages;
///     - Question messages;
///     - Administrators Actions's messages;
///
/// Only works if a feature is enabled.
class message_hider final : public feature {
private:
    struct text_to_find final {
        std::string start;
        std::optional<std::string> continuation;
        bool skip_nickname_after_start = false;
    }; // struct text_to_find final
    
    using message_to_hide_t = std::variant<text_to_find, types::color>;

    static std::unordered_map<std::string, std::vector<message_to_hide_t>> messages;
    bool skip_next_message = false;

    auto on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool;
public:
    auto on_event(const samp::event_info& event) -> bool override;
}; // class message_hider final : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_MESSAGE_HIDER_H
