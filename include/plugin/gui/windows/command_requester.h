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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_COMMAND_REQUESTER_H
#define GADMIN_PLUGIN_GUI_WINDOWS_COMMAND_REQUESTER_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/hotkey.h"
#include "plugin/samp/events/event.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include "plugin/samp/events/send_command.h" // IWYU pragma: keep
#include "plugin/samp/events/server_message.h"
#include "plugin/gui/gui.h"

namespace plugin::gui::windows {

/// Window for handling command requests.
///
/// Provides interface for requesting and approving commands with different
/// parameter types. Supports command parsing and response handling.
class command_requester final : public window {
private:
    struct command_t final {
        enum class type_t : std::uint8_t {
            none,
            reason,
            answer
        }; // enum class type_t : std::uint8_t

        enum class param_t : std::uint8_t {
            id,
            number,
            number_optional,
            text
        }; // enum class param_t : std::uint8_t

        type_t type;
        std::string name;
        std::uint8_t level;
        std::vector<param_t> params;
    }; // struct command_t final

    struct parsed_request_t final {
        command_t command;
        std::optional<std::uint16_t> receiver_id;

        explicit parsed_request_t(const command_t& command, const std::optional<std::uint16_t>& receiver_id)
            : command(std::move(command)), receiver_id(std::move(receiver_id)) {}
    }; // struct parsed_request_t final

    struct request_t final {
        std::optional<std::uint16_t> receiver_id;
        std::string sender_nickname;
        std::uint16_t sender_id;
        std::string full_command;
        command_t command;
    }; // struct request_t final

    static constexpr float fonts_size = 18;
    static const std::vector<command_t> commands;

    std::chrono::steady_clock::time_point time_request_sent;
    std::optional<request_t> current_request;
    
    std::string last_command = "";
    std::string command_to_send = "";

    ImFont* regular_font;
    ImFont* bold_font;

    std::chrono::steady_clock::time_point time_to_send_command;
    hotkey approve_request_hotkey;

    auto try_parse_request(const std::string_view& usage) const -> std::optional<parsed_request_t>;
    auto try_handle_new_request(const std::string& text) -> bool;
    auto try_handle_approved_request(const std::string& text, const types::color& color) -> bool;

    auto approve_request() -> void;
    
    auto on_send_command(const samp::out_event<samp::event_id::send_command>& event) -> bool;
    auto on_server_message(const samp::event<samp::event_id::server_message>& event) -> bool;
public:
    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;

    auto render() -> void override;
    auto on_event(const samp::event_info& event) -> bool override;
    
    /// Create admins window instance.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    /// @return          Unique pointer to window.
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    /// Construct the window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    explicit command_requester(types::not_null<gui_initializer*> child);
}; // class command_requester final : public window 

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::command_requester::get_id() const -> types::zstring_t {
    return "windows::command_requester";
}

inline auto plugin::gui::windows::command_requester::get_name() const -> types::zstring_t {
    return "Запрос формы";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_COMMAND_REQUESTER_H
