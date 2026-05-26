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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_REPORT_NETWORK_H
#define GADMIN_PLUGIN_GUI_WINDOWS_REPORT_NETWORK_H

#include <chrono>
#include <string>
#include <cstdint>
#include <optional>
#include <cstdint>
#include <queue>
#include "plugin/samp/events/server_message.h"
#include "plugin/samp/events/dialog.h"
#include "plugin/types/not_null.h" 
#include "plugin/gui/hotkey.h"

namespace plugin::gui::windows::report {

class initializer;

// Network part of the report window. This class manages the current report and
// searches for new ones via a hotkey that the user can activate. It also handles
// window opening/closing and related animations.
class network final {
public:
    /// Dialog action in the /reports dialog.
    enum class dialog_action : std::uint8_t {
        spectate,     ///< Spectate the player.
        answer,       ///< Answer to the player.
        remove,       ///< Remove the report.
        block,        ///< Block the player's abillity to send the reports.
        transfer,     ///< Tranfer the report to administrators/helpers.
        set_map_point ///< Set a point on the map for the player.
    }; // enum class dialog_action : std::uint8_t

    /// Custom action supported by the report window.
    enum class custom_action : std::uint8_t {
        open_stats_dialog, ///< Open player's statistics.
        open_pame_dialog,  ///< Open player's pame.
        send_to_a_chat     ///< Send the text of the report to the /a or /h chat.
    }; // enum class custom_action : std::uint8_t
private:
    enum class report_type : std::uint8_t {
        question,
        complaint,
        waiting,
        none
    }; // enum class report_type : std::uint8_t

    struct dialog_response final {
        dialog_action action;
        std::string message = {};
        std::uint8_t block_list_item_id = 0;
    }; // struct dialog_response final

    struct multiline_answer_info final {
        std::queue<std::string> lines;
        std::chrono::steady_clock::time_point time;
    }; // struct multiline_answer_info final

    types::not_null<initializer*> child;
    hotkey switch_window_hotkey;
    hotkey try_accept_last_report_hotkey;

    bool resetting_report : 1 = false;
    bool window_active : 1 = false;
    bool closing_window : 1 = false;
    bool searching_reports : 1 = false;
    bool dialog_active : 1 = false;
    bool notification_active : 1 = false;

    std::chrono::steady_clock::time_point time_holding_report;
    std::chrono::steady_clock::time_point time_switched_window;
    
    std::uint16_t dialog_id = 0;

    std::optional<dialog_response> current_response;
    std::optional<multiline_answer_info> multiline_answer;

    report_type current_report_type = report_type::none;

    auto try_accept_last_report() -> void;
    auto try_handle_report_searching(const std::string& text) -> bool;
    auto try_handle_active_reports_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool;
    auto try_handle_active_report_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool;
    auto write_answer_in_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> void;

    auto on_dialog_response(const samp::out_event<samp::event_id::dialog_response>& id) -> bool;
    auto on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool;
    auto on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool;

    auto open_window() -> void;
    auto open_window_with_dialog() -> void;
    auto close_window() -> void;
    auto switch_window() -> void;

    auto close_dialog() -> void;
    auto close_report() -> void;

    auto handle_multiline_answer() -> void;
    auto handle_remind_notification() -> void;
public:
    /// Details of the active report.
    struct active_report_t final {
        std::string nickname;                             ///< Report sender's nickname.
        std::string time_sent;                            ///< Time when the report was sent in the `HH:MM:SS` format.
        std::string text;                                 ///< Text of the report.
        std::uint16_t id;                                 ///< Report sender's ID.
        std::chrono::steady_clock::time_point time_taken; ///< Time when the report was taken by the user.
    }; // struct active_report_t final

    /// Current report.
    std::optional<active_report_t> active_report;

    /// Send the dialog action.
    ///
    /// @param action[in]        Dialog action.
    /// @param optional_text[in] Text if required for the action.
    auto send_dialog_action(dialog_action action, const std::string& optional_text = "") -> void;

    /// Send the custom action.
    ///
    /// @param action[in] Custom action.
    auto send_custom_action(custom_action action) -> void;
    
    /// Send an answer to the report.
    ///
    /// @param answer[in] Text of the answer.
    auto send_answer(const std::string& answer) -> void;

    /// Block the player's abillity to send the reports.
    ///
    /// @param reason[in]             Reason of the block.
    /// @param block_list_item_id[in] List Item ID of the block button (10min / 30min / 60min / 90min).
    auto block_report(const std::string& reason, std::uint8_t block_list_item_id) -> void;

    /// Check if can save user's send of the `/ans` in the configuration.
    ///
    /// @return Whether we can save user's send of the `/ans` in the configuration.
    auto can_save_answer() const -> bool;

    /// Check if can render the window.
    ///
    /// @return Whether can render the window.
    auto can_render_window() -> bool;

    /// Send SA:MP event to the report window.
    ///
    /// @param event[in] SA:MP event information.
    /// @return          Whether the event should continue processing.
    auto on_event(const samp::event_info& event) -> bool;

    /// Send window's message to the report window.
    ///
    /// @param message[in]            Message ID.
    /// @param wparam[in], lparam[in] Message parameters.
    /// @return                       Whether the message should continue processing.
    auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool;

    /// Construct the class.
    ///
    /// @param child[in] Valid pointer to the report initializer. 
    explicit network(types::not_null<initializer*> child);
}; // class network final

} // namespace plugin::gui::windows::report

#endif // GADMIN_PLUGIN_GUI_WINDOWS_REPORT_NETWORK_H
