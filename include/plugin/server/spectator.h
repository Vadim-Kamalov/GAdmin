#ifndef GADMIN_PLUGIN_SERVER_SPECTATOR_H
#define GADMIN_PLUGIN_SERVER_SPECTATOR_H

#include "plugin/gui/widgets/joystick.h"
#include "plugin/samp/core/remote_player.h"
#include "plugin/samp/core/synchronization.h"
#include "plugin/samp/network/event_handler.h"
#include "plugin/samp/core/text_draw.h"
#include "plugin/samp/core/3d_text.h"
#include "plugin/samp/core/dialog.h"
#include "plugin/samp/core/menu.h"
#include "plugin/server/user.h"
#include "plugin/utils.h"
#include <format>

namespace plugin::server {

struct spectator_information {
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
}; // struct spectator_information

class spectator {
private:
    static inline bool active = false;
    static inline std::uint16_t text_draw_id = 0;
    static inline std::uint16_t stage_3d_text_id = 0;
    static inline spectator_information information;
    static inline bool keys_down[std::to_underlying(samp::synchronization_key::count)];

    static inline bool checking_statistics = false;
    static inline std::chrono::steady_clock::time_point last_reload;

    static bool on_show_text_draw(const samp::text_draw& text_draw);
    static bool on_text_draw_set_string(const samp::text_draw_string_setter& text_draw_setter);
    static bool on_text_draw_hide(const samp::text_draw_hider& text_draw);

    static bool on_show_3d_text(const samp::creator_3d_text& creator_3d_text);
    static bool on_remove_3d_text(const samp::remover_3d_text& remover_3d_text);

    static bool on_show_dialog(const samp::dialog& dialog);

    static bool on_player_synchronization(const samp::player_synchronization& synchronization);
    static bool on_vehicle_synchronization(const samp::vehicle_synchronization& synchronization);
    static bool on_passenger_synchronization(const samp::passenger_synchronization& synchronization);
    static bool on_bullet_synchronization(const samp::bullet_synchronization& synchronization);

    static void update_available_information() noexcept;

    static std::string convert_possible_absence_text(const std::string& text) noexcept;
    static void clear_keys_down() noexcept;
public:
    enum class camera_switch_state_t { none, player, vehicle };
    enum class platform_t { none, desktop, mobile };
    enum class menu_option : std::uint8_t {
        next,
        reload,
        back,
        statistics,
        sessions,
        frisk,
        exit
    }; // enum class menu_option : std::uint8_t
public:
    static inline std::string nickname = "";
    static inline std::uint16_t id = SERVER_MAX_PLAYERS + 1;
    static inline samp::remote_player player = samp::remote_player(0);

    static inline samp::synchronization_type last_synchronization = samp::synchronization_type::player;
    static inline camera_switch_state_t camera_switch_state = camera_switch_state_t::none;
    static inline platform_t platform = platform_t::none;

    static inline gui::widgets::joystick joystick;
    static inline std::chrono::steady_clock::time_point last_checked;

    static inline bool is_active() noexcept;
    static inline void set_status(bool status) noexcept;

    static void assign(std::uint16_t new_id) noexcept;
    static spectator_information get_information() noexcept;

    template<menu_option option>
    static inline void send_menu_option() noexcept;

    static inline bool& get_key_state(const samp::synchronization_key& key) noexcept;

    static bool on_event(const samp::event_type& type, std::uint8_t id, samp::bit_stream* stream);
    static void main_loop();
}; // class spectator

} // namespace plugin::server

inline bool
plugin::server::spectator::is_active() noexcept {
    return active && player.is_available() && user::is_on_alogin();
}

inline void
plugin::server::spectator::set_status(bool status) noexcept {
    active = status;
}
    
template<plugin::server::spectator::menu_option option>
inline void
plugin::server::spectator::send_menu_option() noexcept {
    samp::menu::select(std::to_underlying(option));
}

inline bool&
plugin::server::spectator::get_key_state(const samp::synchronization_key& key) noexcept {
    return keys_down[std::to_underlying(key)];
}

template<>
struct std::formatter<plugin::server::spectator::platform_t> : std::formatter<std::string_view> {
    auto format(const plugin::server::spectator::platform_t& platform, std::format_context& ctx) const {
        static constexpr plugin::utils::zstring_t platforms[] = { "Неизвестно", "Desktop", "Mobile" };
        return std::formatter<std::string_view>::format(platforms[std::to_underlying(platform)], ctx);
    }
}; // struct std::formatter<plugin::server::spectator::platform_t> : std::formatter<std::string_view>

#endif // GADMIN_PLUGIN_SERVER_SPECTATOR_H
