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

#ifndef GADMIN_PLUGIN_MISC_FEATURES_MESSAGE_RECOLORER_H
#define GADMIN_PLUGIN_MISC_FEATURES_MESSAGE_RECOLORER_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/server_message.h"
#include "plugin/types/color.h"
#include <functional>
#include <string>

namespace plugin::misc::features {

/// Represents a feature that allows recoloring specific
/// messages based on user configuration. It supports inline
/// color replacement in the text if the underlying color of
/// the message matches the color specified in curly braces,
/// e.g., `{33AA33}` (where the color is 0x??33AA33). The
/// content inside the curly braces will be replaced according
/// to the user's settings.
class message_recolorer final : public feature {
private:
    using find_callback_t = std::function<bool(const std::string_view&, const types::color&)>;
    using messages_to_recolor_t = std::unordered_map<std::string, find_callback_t>;

    static messages_to_recolor_t messages_to_recolor;
    bool change_next_message_color = false;
    types::color new_message_color;

    auto get_recolored_text(const std::string_view& text, const types::color& original_color) const -> std::string;
    auto on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool;
public:
    auto on_event(const samp::event_info& event) -> bool override;
}; // class message_recolorer final : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_MESSAGE_RECOLORER_H
