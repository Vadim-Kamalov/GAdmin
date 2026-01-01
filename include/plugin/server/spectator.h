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

#ifndef GADMIN_PLUGIN_SERVER_SPECTATOR_H
#define GADMIN_PLUGIN_SERVER_SPECTATOR_H

#include "plugin/gui/hotkey.h"
#include "plugin/gui/widgets/joystick.h"
#include "plugin/samp/core/remote_player.h"
#include "plugin/samp/core/menu.h"
#include "plugin/server/user.h"
#include "plugin/types/simple.h"
#include "plugin/samp/events/synchronization.h"
#include "plugin/samp/events/spectating.h"
#include "plugin/samp/events/dialog.h"
#include "plugin/samp/events/3d_text.h"
#include "plugin/samp/events/text_draw.h"
#include "plugin/samp/events/event.h"
#include <format>

namespace plugin::server {

/// Represents all spectator information that can be retrieved from the `spectator::get_information()` method.
struct spectator_information final {
    float armor = 0;                       ///< Spectator's armor.
    std::int32_t ping = 0;                 ///< Spectator's ping on the server.
    std::uint32_t health = 0;              ///< Spectator's health.
    std::uint32_t account_id = 0;          ///< Spectator's account ID.
    std::string weapon = "N/A";            ///< Spectator's weapon in string format.
    std::string money_hand = "N/A";        ///< Spectator's money on hand.
    std::string money_bank = "N/A";        ///< Spectator's money in their bank account.
    std::string fraction = "N/A";          ///< Spectator's faction.
    std::string rank = "N/A";              ///< Spectator's rank in their current faction.
    std::string vehicle = "N/A";           ///< Spectator's vehicles, separated by spaces.
    std::string house = "N/A";             ///< Spectator's house.
    std::string vip = "N/A";               ///< Spectator's VIP status.
    std::string registration_date = "N/A"; ///< Spectator's registration date in `DD.MM.YYYY` format.
    std::uint8_t warnings = 0;             ///< Spectator's warnings (range: `[0; 2]`).
    std::uint8_t stage = 0;                ///< Spectator's stage of death (range: `[0; 2]`).
    std::uint8_t world = 0;                ///< Spectator's virtual world index.
    std::uint16_t move_speed_current = 0;  ///< Spectator's current movement speed (on foot or in a vehicle).
    std::uint16_t move_speed_max = 0;      ///< Spectator's maximum speed (vehicle or model).
    std::uint32_t total_shots = 0;         ///< Spectator's total shots fired.
    std::uint16_t hit_shots = 0;           ///< Spectator's shots that hit a target.
}; // struct spectator_information final

/// Provides methods for interacting with the player being spectated by the user.
class spectator final {
private:
    static inline bool active = false;

    static inline std::uint16_t previous_id = 0;
    static inline std::uint16_t stage_3d_text_id = 0;

    static inline spectator_information information;
    static inline std::chrono::steady_clock::time_point last_reload;
    static inline std::chrono::steady_clock::time_point time_before_check_statistics;
    
    static inline bool keys_down[std::to_underlying(samp::synchronization_key::count)];
    static inline bool can_render_interface = true;
    static inline bool checking_statistics = false;

    static auto on_show_text_draw(const samp::event<samp::event_id::show_text_draw>& text_draw) -> bool;
    static auto on_text_draw_set_string(const samp::event<samp::event_id::set_text_draw_string>& text_draw) -> bool;
    static auto on_show_3d_text(const samp::event<samp::event_id::create_3d_text>& created_3d_text) -> bool;
    static auto on_remove_3d_text(const samp::event<samp::event_id::remove_3d_text>& removed_3d_text) -> bool;
    static auto on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool;
    static auto on_spectating_player(const samp::event<samp::event_id::spectating_player>& player) -> bool;
    static auto on_spectating_vehicle() -> bool;
    static auto on_player_synchronization(const samp::packet<samp::event_id::player_synchronization>& synchronization) -> bool;
    static auto on_vehicle_synchronization(const samp::packet<samp::event_id::vehicle_synchronization>& synchronization) -> bool;
    static auto on_passenger_synchronization(const samp::packet<samp::event_id::passenger_synchronization>& synchronization) -> bool;
    static auto on_bullet_synchronization(const samp::packet<samp::event_id::bullet_synchronization>& synchronization) -> bool;

    static auto switch_interface_render_state(gui::hotkey&) -> void;
    static auto update_available_information() noexcept -> void;
    static auto convert_possible_absence_text(const std::string& text) noexcept -> std::string;
    static auto clear_keys_down() noexcept -> void;

    static auto assign(std::uint16_t new_id) noexcept -> void;
    static auto assign(std::uint16_t new_id, const std::string_view& new_nickname) noexcept -> void;
    static auto update_spectator_details() noexcept -> void;
    static auto request_checking_statistics() noexcept -> void;
public:
    /// Camera switch states.
    enum class camera_switch_state_t : std::uint8_t {
        none,   ///< None.
        player, ///< Switch to player.
        vehicle ///< Switch to vehicle.
    }; // enum class camera_switch_state_t

    /// Spectator's possible platforms.
    enum class platform_t : std::uint8_t {
        none,    ///< None or unknown.
        desktop, ///< Desktop.
        mobile   ///< Mobile.
    }; // enum class platform_t

    /// Menu options for interacting with spectator mode.
    enum class menu_option : std::uint8_t {
        next,       ///< Go to the next player.
        reload,     ///< Reload the camera.
        back,       ///< Go to the previous player.
        statistics, ///< View spectator's statistics.
        sessions,   ///< View spectator's active sessions.
        frisk,      ///< View spectator's inventory.
        exit        ///< Exit spectator mode.
    }; // enum class menu_option

    /// Descriptions of all menu options.
    static constexpr types::zstring_t menu_option_descriptions[] = {
        "Следующий игрок",                  ///< menu_option::next
        "Обновить /sp",                     ///< menu_option::reload
        "Предыдущий игрок",                 ///< menu_option::back
        "Открыть статистику игрока",        ///< menu_option::statistics
        "Открыть активные сессии игрока",   ///< menu_option::sessions
        "Открыть инвентарь игрока",         ///< menu_option::frisk
        "Покинуть /sp"                      ///< menu_option::exit
    }; // static constexpr types::zstring_t menu_option_descriptions[]

    /// Spectator's nickname.
    static inline std::string nickname = "Неизвестно";

    /// Spectator's ID.
    static inline std::uint16_t id = SERVER_MAX_PLAYERS + 1;

    /// Spectator's information in the SA:MP client.
    static inline samp::remote_player player;

    /// Last synchronization type sent from the spectator.
    static inline samp::synchronization_type last_synchronization = samp::synchronization_type::player;

    /// Current camera switch state based on the spectator's last synchronization type.
    static inline camera_switch_state_t camera_switch_state = camera_switch_state_t::none;

    /// Spectator's platform.
    static inline platform_t platform = platform_t::none;

    /// Spectator's joystick information (mobile platform).
    static inline gui::widgets::joystick joystick;

    /// Time when the user's statistics were last checked.
    static inline std::chrono::steady_clock::time_point last_checked;

    /// Check if the user is in spectator mode.
    ///
    /// @return True if the user is in spectator mode.
    static inline auto is_active() noexcept -> bool;

    /// Check if spectator mode interface elements can be rendered.
    ///
    /// @return True if interface elements can be rendered.
    static inline auto can_render() noexcept -> bool;

    /// Retrieve the spectator's current information.
    ///
    /// @return Spectator's information.
    static auto get_information() noexcept -> spectator_information;

    /// Send a menu option to the spectator mode handler.
    ///
    /// @tparam option Menu option to send.
    template<menu_option option>
    static inline auto send_menu_option() noexcept -> void;

    /// Get the state of a spectator's key (pressed or not).
    ///
    /// @param key[in] Key to check.
    /// @return        Reference to the key's state (`true` if pressed).
    static inline auto get_key_state(const samp::synchronization_key& key) noexcept -> bool&;

    /// Handle SA:MP event for the spectator mode.
    ///
    /// @param event[in] SA:MP event information.
    /// @return          Whether the event should continue processing.
    static auto on_event(const samp::event_info& event) -> bool;

    /// Main loop for the spectator mode handler.
    static auto main_loop() -> void;

    /// Register hotkeys for user interaction with spectator mode.
    ///
    /// @param handler[in] Pointer to the hotkey handler.
    static auto register_hotkeys(types::not_null<gui::hotkey_handler*> handler) noexcept -> void;
}; // class spectator final

} // namespace plugin::server

inline auto plugin::server::spectator::is_active() noexcept -> bool {
    return active && player.is_available() && user::is_on_alogin();
}

inline auto plugin::server::spectator::can_render() noexcept -> bool {
    return is_active() && can_render_interface;
}
    
template<plugin::server::spectator::menu_option option>
inline auto plugin::server::spectator::send_menu_option() noexcept -> void {
    samp::menu::select(std::to_underlying(option));
}

inline auto plugin::server::spectator::get_key_state(const samp::synchronization_key& key)
    noexcept -> bool&
{
    return keys_down[std::to_underlying(key)];
}

template<>
struct std::formatter<plugin::server::spectator::platform_t> : std::formatter<std::string_view> {
    auto format(const plugin::server::spectator::platform_t& platform, std::format_context& ctx) const {
        static constexpr plugin::types::zstring_t platforms[] = { "Неизвестно", "Desktop", "Mobile" };
        return std::formatter<std::string_view>::format(platforms[std::to_underlying(platform)], ctx);
    }
}; // struct std::formatter<plugin::server::spectator::platform_t> : std::formatter<std::string_view>

#endif // GADMIN_PLUGIN_SERVER_SPECTATOR_H
