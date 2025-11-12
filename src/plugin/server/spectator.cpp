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

#include "plugin/server/spectator.h"
#include "plugin/game/ped_model.h"
#include "plugin/game/vehicle.h"
#include "plugin/gui/hotkey.h"
#include "plugin/gui/icon.h"
#include "plugin/gui/notify.h"
#include "plugin/samp/core/vehicle.h"
#include "plugin/samp/core/dialog.h"
#include "plugin/samp/core/player_pool.h"
#include "plugin/samp/utils.h"
#include "plugin/game/weapon.h"
#include "plugin/plugin.h"
#include "plugin/types/u8regex.h"

auto plugin::server::spectator::on_show_text_draw(const samp::event<samp::event_id::show_text_draw>& text_draw) -> bool {
    static constexpr types::zstring_t dirty_title = "Adadadad_Dfghsadersasd(111)";
    static constexpr types::zstring_t dirty_body = "2282282~n~$400000~n~90 MP/H~n~100/20~n~M4A1/Pustinniy Orel~n~999 ms~n~127.23.42.123";
    static constexpr ctll::fixed_string text_draw_id_pattern = "~y~\\(\\d+\\)";

    bool hide = (*configuration)["spectator_mode"]["hide_text_draws"];

    // These values of `text_draw.text` received only once after the user had entered the spectator mode; these texts
    // don't visible for the user. (because the server immediately changes it in `samp::event_id::set_text_draw_string`?)
    if (hide && (text_draw.text == dirty_title || text_draw.text == dirty_body))
        return false;

    return !hide || (!ctre::search<text_draw_id_pattern>(text_draw.text) && !text_draw.text.contains("ID Akkay"));
}

auto plugin::server::spectator::on_text_draw_set_string(const samp::event<samp::event_id::set_text_draw_string>& text_draw) -> bool {
    static constexpr ctll::fixed_string spectator_information =
        "ID Akkay.+a: (\\d+)~n~Ha.+e: (\\d+)~n~Ckopoc.+: (\\d+) / \\d+"
        "~n~Opy.+e: .+~n~Ping: \\d+ ms~n~HP: (.+)~n~Android: (.+)~n~Mo.+y.+p: (\\d+)";

    if (auto matches = types::u8regex::search<spectator_information>(text_draw.text)) {
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

auto plugin::server::spectator::on_show_3d_text(const samp::event<samp::event_id::create_3d_text>& text_3d) -> bool {
    static constexpr ctll::fixed_string first_stage_pattern = R"(\(\( Данный персонаж ранен \d+ раз\(-а\) - /dm \d+ \)\))";
    static constexpr ctll::fixed_string second_stage_pattern = R"(\(\( ДАННЫЙ ПЕРСОНАЖ .+ \)\))";

    if (!active || text_3d.attached_player_id == 0xFFFF || text_3d.attached_player_id != id)
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

auto plugin::server::spectator::on_remove_3d_text(const samp::event<samp::event_id::remove_3d_text>& text_3d) -> bool {
    if (active && information.stage != 0 && text_3d.id == stage_3d_text_id)
        information.stage = 0;

    return true;
}

auto plugin::server::spectator::on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool {
    static constexpr ctll::fixed_string warnings_pattern = "Предупреждения: (\\d+)";
    static constexpr ctll::fixed_string start_pattern = "Информация о игроке (.+)\\[(\\d+)]";
    static constexpr ctll::fixed_string information_pattern =
        "Банк: \\$([^\\n]+).*Фракция: ([^\\n]+).*Должность: ([^\\n]+).*Транспорт: ([^\\n]+).*"
        "Дом: ([^\\n]+).*Премиум аккаунт: ([^\\n]+).*Дата регистрации: ([^\\n]+)";

    std::string text = string_utils::remove_samp_colors(dialog.text);
    auto dialog_start = types::u8regex::search<start_pattern>(text);

    if (!dialog_start || !active)
        return true;

    std::uint16_t new_id = std::stoull(dialog_start.get_string<2>());

    if (previous_id != new_id)
        assign(new_id, dialog_start.get_string<1>());

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
    
        std::replace(information.vehicle.begin(), information.vehicle.end(), ',', ' ');
    }

    if (checking_statistics) {
        dialog.send_response(samp::dialog::button::left);
        checking_statistics = false;
        return false;
    }

    return !checking_statistics;
}

auto plugin::server::spectator::on_spectating_player(const samp::event<samp::event_id::spectating_player>& player) -> bool {
    if (!active || previous_id == player.id)
        return true;

    assign(player.id);
    request_checking_statistics();

    return true;
}

auto plugin::server::spectator::on_spectating_vehicle() -> bool {
    if (!active)
        return true;

    request_checking_statistics();

    return true;
}

#define SET_KEY_STATE(KEY, CONDITION) get_key_state(samp::synchronization_key::KEY) = CONDITION

auto plugin::server::spectator::on_player_synchronization(const samp::packet<samp::event_id::player_synchronization>& synchronization)
    -> bool
{
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

auto plugin::server::spectator::on_vehicle_synchronization(const samp::packet<samp::event_id::vehicle_synchronization>& synchronization)
    -> bool
{
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

auto plugin::server::spectator::on_passenger_synchronization(const samp::packet<samp::event_id::passenger_synchronization>& synchronization)
    -> bool
{
    if (synchronization.player_id != id)
        return true;
    
    if (camera_switch_state == camera_switch_state_t::player) {
        send_menu_option<menu_option::reload>();
        clear_keys_down();
    }
    
    last_synchronization = samp::synchronization_type::passenger;
    camera_switch_state = camera_switch_state_t::vehicle;

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

    return true;
}

#undef SET_KEY_STATE

auto plugin::server::spectator::on_bullet_synchronization(const samp::packet<samp::event_id::bullet_synchronization>& synchronization)
    -> bool
{
    information.total_shots++;
    
    if (synchronization.hit_type == 0 || synchronization.hit_type == 3)
        information.hit_shots++;

    return true;
}

auto plugin::server::spectator::switch_interface_render_state(gui::hotkey&) -> void {
    using namespace gui;

    can_render_interface ^= true;

    std::string postfix = (can_render_interface) ? " показаны." : " скрыты.";

    notify::send(notification("Интерфейс в режиме наблюдения", "Теперь окна в режиме наблюдения" + postfix,
                              ICON_WINDOW));
}

auto plugin::server::spectator::update_available_information() noexcept -> void {
    if (!is_active())
        return;

    samp::ped ped = player.get_ped();
    
    if (!ped.is_available())
        return;

    information.ping = *samp::player_pool::get_ping(id);
    information.armor = player.get_armor();
    information.weapon = game::weapon_names[std::to_underlying(ped.get_current_weapon())];
}

auto plugin::server::spectator::convert_possible_absence_text(const std::string& text) noexcept -> std::string {
    return (text == "НЕТ" || text == "Нет") ? "Отсутствует" : text;
}

auto plugin::server::spectator::clear_keys_down() noexcept -> void {
    for (std::uint8_t i = 0; i < std::to_underlying(samp::synchronization_key::count); i++)
        keys_down[i] = false;
}

auto plugin::server::spectator::assign(std::uint16_t new_id) noexcept -> void {
    auto new_nickname = samp::player_pool::get_nickname(new_id);

    if (!new_nickname)
        return;

    assign(new_id, *new_nickname);
}

auto plugin::server::spectator::assign(std::uint16_t new_id, const std::string_view& new_nickname) noexcept -> void {
    id = new_id;
    nickname = std::move(new_nickname);

    if (auto new_player = samp::player_pool::get_remote_player(id); new_player && new_player->get_ped().is_available())
        player = *new_player;

    if (previous_id == id)
        return;

    update_spectator_details();
}

auto plugin::server::spectator::update_spectator_details() noexcept -> void {
    clear_keys_down();
    previous_id = id;
    camera_switch_state = camera_switch_state_t::none;
    information.total_shots = information.hit_shots = 0;
    last_checked = std::chrono::steady_clock::now();
}

auto plugin::server::spectator::request_checking_statistics() noexcept -> void {
    time_before_check_statistics = std::chrono::steady_clock::now();
}

auto plugin::server::spectator::get_information() noexcept -> spectator_information {
    update_available_information();
    return information;
}

auto plugin::server::spectator::on_event(const samp::event_info& event) -> bool {
    switch (event.type) {
        case samp::event_type::incoming_rpc: {
            if (event == samp::event_id::show_text_draw)
                return on_show_text_draw(event.create<samp::event_id::show_text_draw>());
            else if (event == samp::event_id::set_text_draw_string)
                return on_text_draw_set_string(event.create<samp::event_id::set_text_draw_string>());
            else if (event == samp::event_id::create_3d_text)
                return on_show_3d_text(event.create<samp::event_id::create_3d_text>());
            else if (event == samp::event_id::remove_3d_text)
                return on_show_3d_text(event.create<samp::event_id::create_3d_text>());
            else if (event == samp::event_id::spectating_player)
                return on_spectating_player(event.create<samp::event_id::spectating_player>());
            else if (event == samp::event_id::spectating_vehicle)
                return on_spectating_vehicle();
            else if (event == samp::event_id::show_menu) {
                active = true;
                return !(*configuration)["spectator_mode"]["hide_menu"];
            } else if (event == samp::event_id::hide_menu) {
                active = false;
                last_checked = time_before_check_statistics = {};
                break;
            } else if (event == samp::event_id::show_dialog) {
                if (auto dialog_event = event.create<samp::event_id::show_dialog>()) {
                    return on_show_dialog(dialog_event);
                }
            }

            break;
        }

        case samp::event_type::incoming_packet: {
            if (event == samp::event_id::player_synchronization)
                return on_player_synchronization(event.create<samp::event_id::player_synchronization,
                                                              samp::event_type::incoming_packet>());
            else if (event == samp::event_id::vehicle_synchronization)
                return on_vehicle_synchronization(event.create<samp::event_id::vehicle_synchronization,
                                                               samp::event_type::incoming_packet>());
            else if (event == samp::event_id::passenger_synchronization)
                return on_passenger_synchronization(event.create<samp::event_id::passenger_synchronization,
                                                                 samp::event_type::incoming_packet>());
            else if (event == samp::event_id::bullet_synchronization) {
                return on_bullet_synchronization(event.create<samp::event_id::bullet_synchronization,
                                                              samp::event_type::incoming_packet>());
            }

            break;
        }
        
        default:
            break;
    }

    return true;
}

auto plugin::server::spectator::main_loop() -> void {
    using namespace std::chrono_literals;

    if (!user::is_on_alogin() || !active)
        return;

    auto now = std::chrono::steady_clock::now();

    if (time_before_check_statistics != std::chrono::steady_clock::time_point {} && now - time_before_check_statistics >= 1s) {
        send_menu_option<menu_option::statistics>();
        time_before_check_statistics = {};
        checking_statistics = true;
    }

    if (!player.is_available() || (player.is_available() && !player.get_ped().is_available()))
        if (auto new_player = samp::player_pool::get_remote_player(id))
            player = *new_player;

    if (player.is_available() && player.get_ped().is_available()) {
        if (samp::vehicle vehicle = player.get_vehicle(); vehicle.is_available()) {
            information.move_speed_max = game::get_max_vehicle_model_speed(vehicle.get_model_index());
            return;
        }

        samp::ped ped = player.get_ped();

        information.move_speed_current = ped.get_game_ped().get_speed();
        information.move_speed_max = game::get_max_ped_model_speed(ped.get_model_index());
    
        return;
    }

    if (samp::utils::is_inputs_active() || now - last_reload < 1s)
        return;

    last_reload = now;
    send_menu_option<menu_option::reload>();
}

auto plugin::server::spectator::register_hotkeys(types::not_null<gui::hotkey_handler*> handler) noexcept -> void {
    using namespace gui;

    static hotkey hotkeys[] = {
        hotkey("Выйти из /sp", key_bind({ 'I', 0 }, bind_condition::in_spectator))
            .with_callback([](auto&) { send_menu_option<menu_option::exit>(); }),

        hotkey("Переключить /sp", key_bind({ 'U', 0 }, bind_condition::in_spectator))
            .with_callback([](auto&) { send_menu_option<menu_option::reload>(); }),
        
        hotkey("Следующий игрок в /sp", key_bind({ VK_RIGHT, 0 }, bind_condition::in_spectator))
            .with_callback([](auto&) { send_menu_option<menu_option::next>(); }),

        hotkey("Предыдущий игрок в /sp", key_bind({ VK_LEFT, 0 }, bind_condition::in_spectator))
            .with_callback([](auto&) { send_menu_option<menu_option::back>(); }),

        hotkey("Скрыть/показать интерфейс в /sp", key_bind({ 'N', 0 }, bind_condition::in_spectator))
            .with_callback(switch_interface_render_state)
    };

    for (auto& hotkey : hotkeys)
        handler->add(hotkey);
}
