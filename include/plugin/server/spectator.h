#ifndef GADMIN_PLUGIN_SERVER_SPECTATOR_H
#define GADMIN_PLUGIN_SERVER_SPECTATOR_H

#include "plugin/gui/hotkey.h"
#include "plugin/gui/widgets/joystick.h"
#include "plugin/samp/core/remote_player.h"
#include "plugin/samp/core/menu.h"
#include "plugin/server/user.h"
#include "plugin/types/simple.h"
#include "plugin/samp/events/synchronization.h"
#include "plugin/samp/events/dialog.h"
#include "plugin/samp/events/3d_text.h"
#include "plugin/samp/events/text_draw.h"
#include "plugin/samp/events/event.h"
#include <format>

namespace plugin::server {

struct spectator_information final {
    float armor = 0;
    std::int32_t ping = 0;
    std::uint32_t health = 0, account_id = 0;
    std::string weapon = "N/A";
    std::string money_hand = "N/A";
    std::string money_bank = "N/A";
    std::string fraction = "N/A";
    std::string rank = "N/A";
    std::string vehicle = "N/A";
    std::string house = "N/A";
    std::string vip = "N/A";
    std::string registration_date = "N/A";
    std::uint8_t warnings = 0, stage = 0, world = 0;
    std::uint16_t move_speed_current = 0, move_speed_max = 0;
    std::uint32_t total_shots = 0, hit_shots = 0;
}; // struct spectator_information final

class spectator final {
private:
    static inline bool active = false;
    static inline std::uint16_t text_draw_id = 0;
    static inline std::uint16_t stage_3d_text_id = 0;
    static inline spectator_information information;
    static inline bool keys_down[std::to_underlying(samp::synchronization_key::count)];

    static inline bool can_render_interface = true;
    static inline bool checking_statistics = false;
    static inline std::chrono::steady_clock::time_point last_reload;

    static auto on_show_text_draw(const samp::event<samp::event_id::show_text_draw>& text_draw) -> bool;
    static auto on_text_draw_set_string(const samp::event<samp::event_id::set_text_draw_string>& text_draw) -> bool;
    static auto on_text_draw_hide(const samp::event<samp::event_id::hide_text_draw>& text_draw) -> bool;
    static auto on_show_3d_text(const samp::event<samp::event_id::create_3d_text>& created_3d_text) -> bool;
    static auto on_remove_3d_text(const samp::event<samp::event_id::remove_3d_text>& removed_3d_text) -> bool;
    static auto on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool;
    static auto on_player_synchronization(const samp::packet<samp::event_id::player_synchronization>& synchronization) -> bool;
    static auto on_vehicle_synchronization(const samp::packet<samp::event_id::vehicle_synchronization>& synchronization) -> bool;
    static auto on_passenger_synchronization(const samp::packet<samp::event_id::passenger_synchronization>& synchronization) -> bool;
    static auto on_bullet_synchronization(const samp::packet<samp::event_id::bullet_synchronization>& synchronization) -> bool;

    static auto switch_interface_render_state(gui::hotkey&) -> void;
    static auto update_available_information() noexcept -> void;
    static auto convert_possible_absence_text(const std::string& text) noexcept -> std::string;
    static auto clear_keys_down() noexcept -> void;
public:
    enum class camera_switch_state_t : std::uint8_t { none, player, vehicle };
    enum class platform_t : std::uint8_t { none, desktop, mobile };
    enum class menu_option : std::uint8_t {
        next,
        reload,
        back,
        statistics,
        sessions,
        frisk,
        exit
    }; // enum class menu_option : std::uint8_t

    static constexpr types::zstring_t menu_option_descriptions[] = {
        "Следующий игрок",                  ///< menu_option::next
        "Обновить /sp",                     ///< menu_option::reload
        "Предыдущий игрок",                 ///< menu_option::back
        "Открыть статистику игрока",        ///< menu_option::statistics
        "Открыть активные сессии игрока",   ///< menu_option::sessions
        "Открыть инвентарь игрока",         ///< menu_option::frisk
        "Покинуть /sp"                      ///< menu_option::exit
    }; // static constexpr types::zstring_t menu_option_descriptions[]
public:
    static inline std::string nickname = "Неизвестно";
    static inline std::uint16_t id = SERVER_MAX_PLAYERS + 1;
    static inline samp::remote_player player;

    static inline samp::synchronization_type last_synchronization = samp::synchronization_type::player;
    static inline camera_switch_state_t camera_switch_state = camera_switch_state_t::none;
    static inline platform_t platform = platform_t::none;

    static inline gui::widgets::joystick joystick;
    static inline std::chrono::steady_clock::time_point last_checked;

    static inline auto is_active() noexcept -> bool;
    static inline auto can_render() noexcept -> bool;
    static inline auto set_state(bool state) noexcept -> void;

    static auto assign(std::uint16_t new_id) noexcept -> void;
    static auto get_information() noexcept -> spectator_information;

    template<menu_option option>
    static inline auto send_menu_option() noexcept -> void;

    static inline auto get_key_state(const samp::synchronization_key& key) noexcept -> bool&;

    static auto on_event(const samp::event_info& event) -> bool;
    static auto main_loop() -> void;
    static auto register_hotkeys(types::not_null<gui::hotkey_handler*> handler) noexcept -> void;
}; // class spectator final

} // namespace plugin::server

inline auto plugin::server::spectator::is_active() noexcept -> bool {
    return active && player.is_available() && user::is_on_alogin();
}

inline auto plugin::server::spectator::can_render() noexcept -> bool {
    return is_active() && can_render_interface;
}

inline auto plugin::server::spectator::set_state(bool state) noexcept -> void {
    active = state;
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
