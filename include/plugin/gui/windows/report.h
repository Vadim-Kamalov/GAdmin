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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_REPORT_H
#define GADMIN_PLUGIN_GUI_WINDOWS_REPORT_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/hotkey.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/samp/events/event.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include "plugin/gui/gui.h"
#include "plugin/samp/events/server_message.h"
#include "plugin/samp/events/dialog.h"
#include <nlohmann/json.hpp>
#include <array>
#include <chrono>

namespace plugin::gui::windows {

/// Window for handling player reports.
///
/// Provides interface for viewing and responding to player reports.
/// Supports various actions including spectating, answering, blocking and more.
class report final : public window {
private:
    static constexpr float bold_font_size = 18;
    static constexpr float regular_font_size = 16;
    static constexpr float answer_button_height = 30;
    static constexpr std::size_t max_buttons_per_line = 3;
    static constexpr std::size_t max_action_buttons_lines = 4;
    static constexpr std::chrono::milliseconds animation_duration = 500ms;
    static constexpr int block_time_options[4] = { 10, 30, 60, 90 };

    struct report_information_t final {
        std::string nickname;
        std::string text;
        std::uint16_t id;
        std::chrono::steady_clock::time_point time_taken;
    }; // struct report_information_t final

    struct action_button final {
        widgets::button widget;
        std::function<void()> callback;
    }; // struct action_button final
    
    struct insert_button final {
        std::string name;
        std::string insert;
    }; // struct insert_button final

    enum class dialog_option {
        spectate,
        answer,
        remove,
        block,
        return_to_administration,
        set_map_point
    }; // enum class dialog_option
    
    struct dialog_response final {
        dialog_option option;
        std::optional<std::string> message;
        std::uint8_t block_time = 0;
    }; // struct dialog_response final

    std::uint8_t window_alpha = 0;
    std::uint16_t dialog_id = 0;

    std::chrono::steady_clock::time_point time_received_report;
    std::chrono::steady_clock::time_point time_holding_report;
    std::chrono::steady_clock::time_point time_hint_active;
    std::chrono::steady_clock::time_point time_switched_window;

    bool closing = false;
    bool active = false;
    bool focus = false;
    bool reset = false;
    bool dialog_active = false;
    bool notification_active = false;

    std::optional<report_information_t> current_report;
    std::optional<dialog_response> current_response;
    std::string answer_input;

    ImFont* bold_font;
    ImFont* regular_font;

    hotkey switch_window_hotkey;

    auto get_action_buttons() -> std::array<action_button, 12>;
    auto send_chat_action_button() const -> void;
    auto block_action_button() -> void;

    auto on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool;
    auto on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool;
    auto on_new_report_message(const std::string& nickname, std::uint16_t id) -> bool;
    auto on_report_canceled() -> bool;

    auto open_window() -> void;
    auto open_window_with_dialog() -> void;
    auto close_window() -> void;
    auto switch_window() -> void;

    auto handle_remind_notification() -> void;
    auto get_time_active() const -> std::string;

    auto can_send_response() -> bool;
    auto close_dialog() -> void;
    auto send_response(const dialog_option& option) -> void;
    auto send_input_response(const dialog_option& option) -> void;
    auto close_report() -> void;
    
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(insert_button, name, insert);
public:
    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;
    
    auto render() -> void override;

    auto on_event(const samp::event_info& event) -> bool override;
    auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool override;

    /// Create instance of the current window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    /// @return          Unique pointer to window.
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    /// Construct the window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    explicit report(types::not_null<gui_initializer*> child);
}; // class report final : public window 

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::report::get_id() const -> types::zstring_t {
    return "windows::report";
}

inline auto plugin::gui::windows::report::get_name() const -> types::zstring_t {
    return "Репорт (/greport)";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_REPORT_H
