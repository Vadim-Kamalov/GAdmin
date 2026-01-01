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

#ifndef GADMIN_PLUGIN_GUI_NOTIFY_H
#define GADMIN_PLUGIN_GUI_NOTIFY_H

#include "plugin/types/simple.h"
#include <imgui.h>
#include <chrono>
#include <list>
#include <optional>
#include <string>
#include <functional>
#include <utility>

using namespace std::chrono_literals;

namespace plugin::gui {

// Represents a notification sent to the user.
class notification final {
public:
    using icon_t = types::zstring_t;                              ///< Notification icon type.
    using button_callback_t = std::function<void(notification&)>; ///< Notification button callback.
    using condition_t = std::function<bool()>;                    ///< Notification condition to show.

    /// Represents a button in the notification.
    struct button final {
        /// Button backed information.
        struct backend_t final {
            static inline std::chrono::milliseconds clicked_duration = 300ms;
            static inline std::chrono::milliseconds hovered_duration = 200ms;
            
            ImVec4 color;
            bool hovered_state_previous = false, hovered_state_current = false;
            std::chrono::steady_clock::time_point time[2], hovered_time, clicked_time;

            struct colors_t final {
                ImVec4 hovered = ImGui::GetStyle().Colors[ImGuiCol_Text];
                ImVec4 clicked = ImGui::GetStyle().Colors[ImGuiCol_FrameBgActive];
                ImVec4 text = ImGui::GetStyle().Colors[ImGuiCol_TextDisabled];
            } colors; // struct colors_t final
        }; // struct backend_t final
        
        std::string name;                 ///< Button name.
        button_callback_t callback;       ///< Button callback function executed on click.
        std::optional<backend_t> backend; ///< Button optional backend parameters.
    }; // struct button final

    /// Notification backend information.
    struct backend_t final {
        static inline std::chrono::milliseconds open_close_duration = 200ms;
        static inline std::chrono::milliseconds drop_duration = 100ms;
        float cursor_pos_x;
    }; // struct backend_t final

    /// Type for the pair of the buttons.
    using buttons_t = std::pair<button, button>;

    std::string title;                               ///< Notification title.
    std::string description;                         ///< Notification description.
    std::optional<buttons_t> buttons;                ///< Notification optional buttons.
    std::chrono::steady_clock::time_point time_sent; ///< Time when notification was sent.
    icon_t icon;                                     ///< Notification icon.
    std::chrono::milliseconds duration = 5s;         ///< Notification duration until hide.
    condition_t condition = []{ return true; };      ///< Notification condition to show.
    std::optional<backend_t> backend;                ///< Notification optional backend.

    /// Construct notification with the specified duration on the screen.
    ///
    /// @param new_duration[in] New duration to set.
    /// @return                 Reference to this notification to allow chain-calls.
    auto with_duration(std::chrono::milliseconds new_duration) -> notification&;

    /// Construct notification with the specified buttons.
    ///
    /// @param first[in]  First button to set.
    /// @param second[in] Second button to set.
    /// @return           Reference to this notification to allow chain-calls.
    auto with_buttons(const button& first, const button& second) -> notification&;
    
    /// Construct notification with the specified condition to show.
    ///
    /// @param new_condition[in] New condition to set.
    /// @return                  Reference to this notification to allow chain-calls.
    auto with_condition(condition_t new_condition) -> notification&;

    /// Remove notification from the screen.
    auto remove() -> void;

    /// Construct notification.
    ///
    /// @param title[in]       Notification title.
    /// @parma description[in] Notification description.
    /// @param icon[in]        Notification icon.
    notification(const std::string_view& title, const std::string_view& description, icon_t icon)
        : title(std::move(title)),
          description(std::move(description)),
          icon(icon),
          time_sent(std::chrono::steady_clock::now()) {}
}; // class notification final

/// Notification initialization and management class.
class notify final {
public:
    /// Callback which called on each notification creation.
    using callback_t = std::function<bool(notification&)>;
private:
    static inline std::list<notification> notifications;
    static inline callback_t on_send_callback = [](notification&) { return true; };
public:
    /// Get current notifications on the screen.
    ///
    /// @return Current notifications on the screen.
    static auto get_notifications() noexcept -> std::list<notification>&;

    /// Check if there any notifications on the screen.
    ///
    /// @return True if there any notifications on the screen.
    static auto has_notifications() noexcept -> bool;

    /// Get number of the notification on the screen.
    ///
    /// @return Number of the notification on the screen.
    static auto notifications_count() noexcept -> std::size_t;

    /// Send notification to the user.
    ///
    /// @param to_send[in] Notification to send.
    static auto send(const notification& to_send) -> void;

    /// Set callback for each notification creation.
    ///
    /// @param callback[in] New callback function.
    static auto set_callback(callback_t callback) noexcept -> void;
}; // class notify final

} // namespace plugin::gui

#endif // GADMIN_PLUGIN_GUI_NOTIFY_H
