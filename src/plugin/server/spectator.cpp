#include "plugin/server/spectator.h"
#include "plugin/game/ped_model.h"
#include "plugin/game/vehicle.h"
#include "plugin/samp/core/vehicle.h"
#include "plugin/samp/core/dialog.h"
#include "plugin/samp/core/player_pool.h"
#include "plugin/samp/utils.h"
#include "plugin/game/weapon.h"
#include "plugin/plugin.h"
#include "plugin/log.h"
#include "plugin/types/u8regex.h"

using namespace std::chrono_literals;

bool
plugin::server::spectator::on_show_text_draw(const samp::event<samp::event_id::show_text_draw>& text_draw) {
    static constexpr types::zstring_t dirty_title = "Adadadad_Dfghsadersasd(111)";
    static constexpr types::zstring_t dirty_body = "2282282~n~$400000~n~90 MP/H~n~100/20~n~M4A1/Pustinniy Orel~n~999 ms~n~127.23.42.123";
    static constexpr ctll::fixed_string text_draw_id_pattern = "~y~\\((\\d+)\\)";

    bool hide = (*configuration)["misc"]["hide_spectator_text_draws"];

    // These values of `text_draw.text` received only once after the user had entered the spectator mode; these texts
    // don't visible for the user. (because the server immediately changes it in `samp::event_id::set_text_draw_string`?)
    if (hide && (text_draw.text == dirty_title || text_draw.text == dirty_body))
        return false;

    if (auto [ whole, id ] = ctre::search<text_draw_id_pattern>(text_draw.text); whole) {
        assign(std::stoul(id.str()));
        return !hide;
    }

    if (text_draw.text.contains("ID Akkay")) {
        text_draw_id = text_draw.id;
        return !hide;
    }

    return true;
}

bool
plugin::server::spectator::on_text_draw_set_string(const samp::event<samp::event_id::set_text_draw_string>& text_draw) {
    static constexpr ctll::fixed_string text_draw_id_pattern = "~y~\\((\\d+)\\)";
    static constexpr ctll::fixed_string spectator_information =
        "ID Akkay.+a: (\\d+)~n~Ha.+e: (\\d+)~n~Ckopoc.+: (\\d+) / \\d+"
        "~n~Opy.+e: .+~n~Ping: \\d+ ms~n~HP: (.+)~n~Android: (.+)~n~Mo.+y.+p: (\\d+)";

    if (auto [ whole, id ] = ctre::search<text_draw_id_pattern>(text_draw.text); whole) {
        assign(std::stoul(id.str()));
        return true;
    }

    if (auto matches = types::u8regex::search<spectator_information>(text_draw.text)) {
        text_draw_id = text_draw.id;
        
        information.account_id = std::stoul(matches.get_string<1>());
        information.money_hand = matches.get_string<2>();
        information.health = std::stoul(matches.get_string<4>());
        information.world = std::stoul(matches.get_string<6>());
       
        if (player.is_available() && player.get_vehicle().is_available())
            information.move_speed_current = std::stoul(matches.get_string<3>());

        std::string platform_str = matches.get_string<5>();

        if (platform_str == "\x48\x65\xA6")
            platform = platform_t::desktop;
        else if (platform_str == "\x83\x61")
            platform = platform_t::mobile;
        else
            platform = platform_t::none;
    }

    return true;
}

bool
plugin::server::spectator::on_text_draw_hide(const samp::event<samp::event_id::hide_text_draw>& text_draw) {
    if (text_draw.id == text_draw_id)
        active = false;
    
    return true;
}

bool
plugin::server::spectator::on_show_3d_text(const samp::event<samp::event_id::create_3d_text>& text_3d) {
    static constexpr ctll::fixed_string first_stage_pattern = R"(\(\( Данный персонаж ранен \d+ раз\(-а\) - /dm \d+ \)\))";
    static constexpr ctll::fixed_string second_stage_pattern = R"(\(\( ДАННЫЙ ПЕРСОНАЖ .+ \)\))";

    if (!active)
        return true;

    if (text_3d.attached_player_id == 0xFFFF)
        return true;

    if (text_3d.attached_player_id != id)
        return true;

    if (types::u8regex::search<first_stage_pattern>(text_3d.text)) {
        information.stage = 1;
        stage_3d_text_id = text_3d.id;
        return true;
    }

    if (types::u8regex::search<second_stage_pattern>(text_3d.text)) {
        information.stage = 2;
        stage_3d_text_id = text_3d.id;
        return true;
    }

    information.stage = 0;

    return true;
}

bool
plugin::server::spectator::on_remove_3d_text(const samp::event<samp::event_id::remove_3d_text>& text_3d) {
    if (active && information.stage != 0 && text_3d.id == stage_3d_text_id)
        information.stage = 0;

    return true;
}

bool
plugin::server::spectator::on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) {
    static constexpr ctll::fixed_string warnings_pattern = "Предупреждения: (\\d+)";
    static constexpr ctll::fixed_string information_pattern =
        "Банк: \\$([^\\n]+).*Фракция: ([^\\n]+).*Должность: ([^\\n]+).*Транспорт: ([^\\n]+).*"
        "Дом: ([^\\n]+).*Премиум аккаунт: ([^\\n]+).*Дата регистрации: ([^\\n]+)";

    if (!dialog.text.contains("Информация о игроке") || !checking_statistics || !active)
        return true;

    std::string text = string_utils::remove_samp_colors(dialog.text);
    auto matches = types::u8regex::search<warnings_pattern>(text);

    information.warnings = (matches) ? std::stoul(matches.get_string<1>()) : 0;

    if (auto matches = types::u8regex::search<information_pattern>(text)) {
        information.money_bank = matches.get_string<1>();
        information.fraction = convert_possible_absence_text(matches.get_string<2>());
        information.rank = convert_possible_absence_text(matches.get_string<3>());
        information.vehicle = convert_possible_absence_text(matches.get_string<4>());
        information.house = convert_possible_absence_text(matches.get_string<5>());
        information.vip = convert_possible_absence_text(matches.get_string<6>());
        information.registration_date = matches.get_string<7>();
    
        checking_statistics = false;
    
        std::replace(information.vehicle.begin(), information.vehicle.end(), ',', ' ');
        dialog.send_response(samp::dialog::button::left);
    }
    
    return false;
}

#define SET_KEY_STATE(KEY, CONDITION) get_key_state(samp::synchronization_key::KEY) = CONDITION

bool
plugin::server::spectator::on_player_synchronization(const samp::packet<samp::event_id::player_synchronization>& synchronization) {
    if (synchronization.player_id != id)
        return true;
    
    if (camera_switch_state == camera_switch_state_t::vehicle) {
        send_menu_option<menu_option::reload>();
        clear_keys_down();
    }

    switch (platform) {
        case platform_t::desktop:
            SET_KEY_STATE(w, synchronization.up_down_keys == 0xFF80);
            SET_KEY_STATE(a, synchronization.left_right_keys == 0xFF80);
            SET_KEY_STATE(s, synchronization.up_down_keys == 0x80);
            SET_KEY_STATE(d, synchronization.left_right_keys == 0x80);
            SET_KEY_STATE(alt, synchronization.keys_data & 0x400);
            SET_KEY_STATE(shift, synchronization.keys_data & 0x20);
            SET_KEY_STATE(space, synchronization.keys_data & 0x8);
            SET_KEY_STATE(f, synchronization.keys_data & 0x10);
            SET_KEY_STATE(c, synchronization.keys_data & 0x2);
            SET_KEY_STATE(rmb, synchronization.keys_data & 0x4);
            SET_KEY_STATE(lmb, synchronization.keys_data & 0x80);
            break;
        case platform_t::mobile:
            SET_KEY_STATE(hit, synchronization.keys_data & 0x4);
            SET_KEY_STATE(alt, synchronization.keys_data & 0x400);
            SET_KEY_STATE(f, synchronization.keys_data & 0x10);
            SET_KEY_STATE(jump_run, synchronization.keys_data & 0x8);
            SET_KEY_STATE(aim, synchronization.keys_data & 0x80);

            joystick.update(synchronization.left_right_keys, synchronization.up_down_keys);

            break;
        case platform_t::none:
            break;
    }

    last_synchronization = samp::synchronization_type::player;
    camera_switch_state = camera_switch_state_t::player;

    return true;
}

bool
plugin::server::spectator::on_vehicle_synchronization(const samp::packet<samp::event_id::vehicle_synchronization>& synchronization) {
    if (synchronization.player_id != id)
        return true;
    
    if (camera_switch_state == camera_switch_state_t::player) {
        send_menu_option<menu_option::reload>();
        clear_keys_down();
    }

    switch (platform) {
        case platform_t::desktop:
            SET_KEY_STATE(w, synchronization.keys_data & 0x8);
            SET_KEY_STATE(a, synchronization.left_right_keys == 0xFF80);
            SET_KEY_STATE(s, synchronization.keys_data & 0x20);
            SET_KEY_STATE(d, synchronization.left_right_keys == 0x80);
            SET_KEY_STATE(h, synchronization.keys_data & 0x2);
            SET_KEY_STATE(space, synchronization.keys_data & 0x80);
            SET_KEY_STATE(ctrl, synchronization.keys_data & 0x1);
            SET_KEY_STATE(alt, synchronization.keys_data & 0x4);
            SET_KEY_STATE(q, synchronization.keys_data & 0x100);
            SET_KEY_STATE(e, synchronization.keys_data & 0x40);
            SET_KEY_STATE(f, synchronization.keys_data & 0x10);
            SET_KEY_STATE(up, synchronization.up_down_keys == 0xFF80);
            SET_KEY_STATE(down, synchronization.up_down_keys == 0x80);
            break;
        case platform_t::mobile:
            SET_KEY_STATE(signal, synchronization.keys_data & 0x2);
            SET_KEY_STATE(forward, synchronization.keys_data & 0x8);
            SET_KEY_STATE(braking, synchronization.keys_data & 0x28);
            SET_KEY_STATE(backward, synchronization.keys_data & 0x20);
            SET_KEY_STATE(two, synchronization.keys_data & 0x200);
            SET_KEY_STATE(f, synchronization.keys_data & 0x10);

            joystick.update(synchronization.left_right_keys, synchronization.up_down_keys);

            break;
        case platform_t::none:
            break;
    }

    last_synchronization = samp::synchronization_type::vehicle;
    camera_switch_state = camera_switch_state_t::vehicle;

    return true;
}

bool
plugin::server::spectator::on_passenger_synchronization(const samp::packet<samp::event_id::passenger_synchronization>& synchronization) {
    if (synchronization.player_id != id)
        return true;
    
    if (camera_switch_state == camera_switch_state_t::player) {
        send_menu_option<menu_option::reload>();
        clear_keys_down();
    }

    if (platform == platform_t::mobile)
        return true;

    SET_KEY_STATE(w, synchronization.keys_data & 0x8);
    SET_KEY_STATE(a, synchronization.left_right_keys == 0xFF80);
    SET_KEY_STATE(s, synchronization.keys_data & 0x20);
    SET_KEY_STATE(d, synchronization.left_right_keys == 0x80);
    SET_KEY_STATE(h, synchronization.keys_data & 0x2);
    SET_KEY_STATE(space, synchronization.keys_data & 0x80);
    SET_KEY_STATE(ctrl, synchronization.keys_data & 0x1);
    SET_KEY_STATE(alt, synchronization.keys_data & 0x4);
    SET_KEY_STATE(q, synchronization.keys_data & 0x100);
    SET_KEY_STATE(e, synchronization.keys_data & 0x40);
    SET_KEY_STATE(f, synchronization.keys_data & 0x10);
    SET_KEY_STATE(up, synchronization.up_down_keys == 0xFF80);
    SET_KEY_STATE(down, synchronization.up_down_keys == 0x80);

    last_synchronization = samp::synchronization_type::passenger;
    camera_switch_state = camera_switch_state_t::vehicle;

    return true;
}

#undef SET_KEY_STATE

bool
plugin::server::spectator::on_bullet_synchronization(const samp::packet<samp::event_id::bullet_synchronization>& synchronization) {
    information.total_shots++;
    
    if (synchronization.hit_type == 0 || synchronization.hit_type == 3)
        information.hit_shots++;

    return true;
}

void
plugin::server::spectator::update_available_information() noexcept {
    if (!is_active())
        return;

    samp::ped ped = player.get_ped();
    
    if (!ped.is_available())
        return;

    information.ping = *samp::player_pool::get_ping(id);
    information.armor = player.get_armor();
    information.weapon = game::weapon_names[std::to_underlying(ped.get_current_weapon())];
}

std::string
plugin::server::spectator::convert_possible_absence_text(const std::string& text) noexcept {
    return (text == "НЕТ" || text == "Нет") ? "Отсутствует" : text;
}

void
plugin::server::spectator::clear_keys_down() noexcept {
    for (std::uint8_t i = 0; i < std::to_underlying(samp::synchronization_key::count); i++)
        keys_down[i] = false;
}

void
plugin::server::spectator::assign(std::uint16_t new_id) noexcept {
    auto now = std::chrono::steady_clock::now();
    
    if (id == new_id || now - last_checked < 1s || samp::dialog::is_active() || checking_statistics)
        return;
    
    auto new_nickname = samp::player_pool::get_nickname(new_id);

    if (!new_nickname) {
        log::error("failed to server::spectator::assign({}), player_pool::error = {} (on get_nickname)",
                   new_id, std::to_underlying(new_nickname.error()));
        return;
    }
    
    auto new_player = samp::player_pool::get_remote_player(new_id);

    if (!new_player || !new_player->get_ped().is_available())
        return; // No need to report that because it occurs very often (server-related problems?).

    id = new_id;
    nickname = *new_nickname;
    player = *new_player;
    active = true;

    send_menu_option<menu_option::statistics>();
    clear_keys_down();

    checking_statistics = true;
    camera_switch_state = camera_switch_state_t::none;
    last_checked = now;
}

plugin::server::spectator_information
plugin::server::spectator::get_information() noexcept {
    update_available_information();
    return information;
}

bool
plugin::server::spectator::on_event(const samp::event_info& event) {
    if (event == samp::event_type::incoming_rpc) {
        if (event == samp::event_id::show_text_draw)
            return on_show_text_draw(event.create<samp::event_id::show_text_draw>());
        else if (event == samp::event_id::set_text_draw_string)
            return on_text_draw_set_string(event.create<samp::event_id::set_text_draw_string>());
        else if (event == samp::event_id::hide_text_draw)
            return on_text_draw_hide(event.create<samp::event_id::hide_text_draw>());
        else if (event == samp::event_id::create_3d_text)
            return on_show_3d_text(event.create<samp::event_id::create_3d_text>());
        else if (event == samp::event_id::remove_3d_text)
            return on_remove_3d_text(event.create<samp::event_id::remove_3d_text>());
        else if (event == samp::event_id::show_menu)
            return !(*configuration)["misc"]["hide_spectator_menu"];
        else if (event == samp::event_id::show_dialog) {
            if (auto dialog_event = event.create<samp::event_id::show_dialog>()) {
                return on_show_dialog(dialog_event);
            }
        }
    } else if (event == samp::event_type::incoming_packet) {
        if (event == samp::event_id::player_synchronization)
            return on_player_synchronization(event.create<samp::event_id::player_synchronization, samp::event_type::incoming_packet>());
        if (event == samp::event_id::vehicle_synchronization)
            return on_vehicle_synchronization(event.create<samp::event_id::vehicle_synchronization, samp::event_type::incoming_packet>());
        if (event == samp::event_id::passenger_synchronization)
            return on_passenger_synchronization(event.create<samp::event_id::passenger_synchronization, samp::event_type::incoming_packet>());
        if (event == samp::event_id::bullet_synchronization) {
            return on_bullet_synchronization(event.create<samp::event_id::bullet_synchronization, samp::event_type::incoming_packet>());
        }
    }

    return true;
}

void
plugin::server::spectator::main_loop() {
    if (!active || !user::is_on_alogin())
        return;

    if (!player.is_available() || (player.is_available() && !player.get_ped().is_available()))
        if (auto new_player = samp::player_pool::get_remote_player(id))
            player = *new_player;

    if (player.get_ped().is_available()) {
        if (samp::vehicle vehicle = player.get_vehicle(); vehicle.is_available()) {
            information.move_speed_max = game::get_max_vehicle_model_speed(vehicle.get_model_index());
            return;
        }

        samp::ped ped = player.get_ped();

        information.move_speed_current = ped.get_game_ped().get_speed();
        information.move_speed_max = game::get_max_ped_model_speed(ped.get_model_index());
    
        return;
    }

    auto now = std::chrono::steady_clock::now();

    if (samp::utils::is_inputs_active() || now - last_reload < 1s)
        return;

    last_reload = now;
    send_menu_option<menu_option::reload>();
}
