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
/// 
/// @file plugin/gui/windows/main/frames/logs.h
/// @brief Defines the logs frame in the GUI.

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_LOGS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_LOGS_H

#include "plugin/common_utils.h"
#include "plugin/gui/widgets/search.h"
#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/gui/windows/main/widgets/submenu.h"
#include "plugin/samp/events/server_message.h"
#include "plugin/samp/events/player_death_notification.h"
#include "plugin/string_utils.h"
#include "plugin/types/color.h"
#include "plugin/types/not_null.h"
#include <cstdint>
#include <deque>

namespace plugin::gui::windows::main::frames {

/// @class logs
/// @brief Represents the logs frame in the GUI.
class logs final : public basic_frame {
private:
    static constexpr float title_font_size = 24;
    static constexpr float common_font_size = 18;
    static constexpr float clear_button_height = 30;

    enum log_type_t : std::uint8_t {
         administration_chat,
         reports,
         actions,
         puhishments,
         ic_chat,
         ooc_chat,
         kills,
         other
    }; // enum log_type_t : std::uint8_t

    struct log_group final {
        struct message final {
            std::string text;
            std::string timestamp;

            explicit message(const std::string_view& text)
                : text(string_utils::remove_samp_colors(text)),
                  timestamp(common_utils::get_current_timestamp()) {}
        }; // struct message final

        struct conditions_t final {
            using callback_t = std::function<bool(const std::string& text, const types::color& color)>;

            std::deque<std::string> start;
            std::deque<types::color> colors;
            std::optional<callback_t> callback;
        }; // struct conditions_t final

        std::string title;
        std::optional<conditions_t> conditions;
        std::deque<message> messages;
    }; // struct log_group final
    
    static std::map<log_type_t, log_group> log_groups;

    types::not_null<initializer*> child;
    widgets::submenu submenu = widgets::submenu("Логи##frames::logs");
    gui::widgets::search search = gui::widgets::search("frames::logs::search");
    std::string message_buffer = "";

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;
    
    static auto is_continuation_start(const std::string& text) noexcept -> bool;
    static auto is_continuation_end(const std::string& text) noexcept -> bool;
    static auto trim_ellipsis(const std::string& text) noexcept -> std::string;

    auto on_unwrapped_message(const std::string& text, const types::color& color) -> void;
    auto on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool;
    auto on_death_notification(const samp::event<samp::event_id::player_death_notification>& notification) const -> bool;

    auto get_filtered_messages(const std::deque<log_group::message>& messages) const -> std::deque<log_group::message>;
    auto handle_message_controls(const std::string& text_to_copy) const -> void;
    auto frame_renderer(std::string& label, std::any& payload) -> void;
public:
    auto render() -> void override;

    /// @brief Handles events for the logs frame.
    /// @param event The SA-MP event information.
    /// @return True if the event was handled, false otherwise.
    auto on_event(const samp::event_info& event) -> bool override;

    /// @brief Constructor for the logs frame.
    /// @param child The GUI initializer.
    explicit logs(types::not_null<initializer*> child);
}; // class logs final

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_LOGS_H
