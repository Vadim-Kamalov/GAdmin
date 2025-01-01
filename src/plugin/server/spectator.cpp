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
#include <regex>

using namespace std::chrono_literals;

bool
plugin::server::spectator::on_show_text_draw(const samp::text_draw& text_draw) {
    static constexpr const char* dirty_title = "Adadadad_Dfghsadersasd(111)";
    static constexpr const char* dirty_body = "2282282~n~$400000~n~90 MP/H~n~100/20~n~M4A1/Pustinniy Orel~n~999 ms~n~127.23.42.123";

    bool hide = (*configuration)["additions"]["hide_spectator_text_draws"];

    // These values of `text_draw.text` received only once after the user had entered the spectator mode; these texts
    // don't visible for the user. (because the server immediately changes it in `samp::text_draw_string_setter`?)
    if (hide && (text_draw.text == dirty_title || text_draw.text == dirty_body))
        return false;

    std::smatch matches;

    if (std::regex_search(text_draw.text, matches, std::regex(R"(~y~\((\d+)\))"))) {
        text_draw_id = text_draw.id;
        assign(std::stoul(matches[1].str()));
        return !hide;
    }

    if (text_draw.text.find("ID Akkay") != std::string::npos)
        return !hide;

    return true;
}

bool
plugin::server::spectator::on_text_draw_set_string(const samp::text_draw_string_setter& text_draw_setter) {
    static constexpr const char* spectator_information =
        "ID Akkay.+a: (\\d+)~n~Ha.+e: (\\d+)~n~Ckopoc.+: (\\d+) / \\d+"
        "~n~Opy.+e: .+~n~Ping: \\d+ ms~n~HP: (.+)~n~Android: (.+)~n~Mo.+y.+p: (\\d+)";

    std::smatch matches;
    
    if (std::regex_search(text_draw_setter.text, matches, std::regex(R"(~y~\((\d+)\))"))) {
        text_draw_id = text_draw_setter.id;
        assign(std::stoul(matches[1].str()));
        return true;
    }

    if (std::regex_search(text_draw_setter.text, matches, std::regex(spectator_information))) {
        information.account_id = std::stoul(matches[1].str());
        information.money_hand = matches[2].str();
        information.health = std::stoul(matches[4].str());
        information.world = std::stoul(matches[6].str());
       
        if (ped.is_available() && ped.get_vehicle().is_available())
            information.move_speed_current = std::stoul(matches[3].str());

        if (matches[5].str() == "\x48\x65\xA6")
            platform = platform_t::desktop;
        else if (matches[5].str() == "\x83\x61")
            platform = platform_t::mobile;
        else
            platform = platform_t::none;
    }

    return true;
}

bool
plugin::server::spectator::on_text_draw_hide(const samp::text_draw_hider& hiden_text_draw) {
    if (hiden_text_draw.id == text_draw_id)
        active = false;
    
    return true;
}

bool
plugin::server::spectator::on_show_3d_text(const samp::creator_3d_text& creator_3d_text) {
    static constexpr const char* first_stage_pattern = R"(\(\( Данный персонаж ранен \d+ раз\(-а\) - /dm \d+ \)\))";
    static constexpr const char* second_stage_pattern = R"(\(\( ДАННЫЙ ПЕРСОНАЖ .+ \)\))";

    if (!active)
        return true;

    if (creator_3d_text.attached_player_id == 0xFFFF)
        return true;

    if (creator_3d_text.attached_player_id != id)
        return true;

    std::smatch matches;

    if (std::regex_search(creator_3d_text.text, matches, std::regex(first_stage_pattern))) {
        information.stage = 1;
        stage_3d_text_id = creator_3d_text.id;
        return true;
    }

    if (std::regex_search(creator_3d_text.text, matches, std::regex(second_stage_pattern))) {
        information.stage = 2;
        stage_3d_text_id = creator_3d_text.id;
        return true;
    }

    information.stage = 0;

    return true;
}

bool
plugin::server::spectator::on_remove_3d_text(const samp::remover_3d_text& remover_3d_text) {
    if (active && information.stage != 0 && remover_3d_text.id == stage_3d_text_id)
        information.stage = 0;

    return true;
}

bool
plugin::server::spectator::on_show_dialog(const samp::dialog& dialog) {
    static constexpr const char* information_pattern =
        "Банк: \\$(.+)[^]+Фракция: (.+)[^]+Должность: (.+)[^]+Транспорт: (.+)[^]+"
        "Дом: (.+)[^]+Премиум аккаунт: (.+)[^]+Дата регистрации: (.+)[^]+";

    if (dialog.text.find("Информация о игроке") == std::string::npos || !checking_statistics || !active)
        return true;

    std::string text = std::regex_replace(dialog.text, std::regex("\\{[0-9A-Fa-f]{6}\\}"), "");
    std::smatch matches;

    information.warnings = (std::regex_search(text, matches, std::regex("Предупреждения: (\\d+)"))) ? std::stoul(matches[1].str()) : 0; 

    if (!std::regex_search(text, matches, std::regex(information_pattern)))
        return true;

    information.money_bank = matches[1].str();
    information.fraction = convert_possible_absence_text(matches[2].str());
    information.rank = convert_possible_absence_text(matches[3].str());
    information.vehicle = convert_possible_absence_text(matches[4].str());
    information.house = convert_possible_absence_text(matches[5].str());
    information.vip = convert_possible_absence_text(matches[6].str());
    information.registration_date = matches[7].str();
    
    checking_statistics = false;
    
    dialog.send_response<samp::dialog::button::left>();
    
    return false;
}

#define SET_KEY_STATE(KEY, CONDITION) get_key_state(samp::synchronization_key::KEY) = CONDITION

bool
plugin::server::spectator::on_player_synchronization(const samp::player_synchronization& synchronization) {
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

            update_joystick(synchronization.left_right_keys, synchronization.up_down_keys);

            break;
        case platform_t::none:
            break;
    }

    camera_switch_state = camera_switch_state_t::player;

    return true;
}

bool
plugin::server::spectator::on_vehicle_synchronization(const samp::vehicle_synchronization& synchronization) {
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

            update_joystick(synchronization.left_right_keys, synchronization.up_down_keys);

            break;
        case platform_t::none:
            break;
    }

    camera_switch_state = camera_switch_state_t::vehicle;

    return true;
}

bool
plugin::server::spectator::on_passenger_synchronization(const samp::passenger_synchronization& synchronization) {
    if (synchronization.player_id != id || platform == platform_t::mobile)
        return true;
    
    if (camera_switch_state == camera_switch_state_t::player) {
        send_menu_option<menu_option::reload>();
        clear_keys_down();
    }

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

    camera_switch_state = camera_switch_state_t::vehicle;

    return true;
}

#undef SET_KEY_STATE

bool
plugin::server::spectator::on_bullet_synchronization(const samp::bullet_synchronization& synchronization) {
    if (synchronization.player_id != id)
        return true;

    information.total_shots++;
    
    if (synchronization.hit_type == 0 || synchronization.hit_type == 3)
        information.hit_shots++;

    return true;
}

void
plugin::server::spectator::update_available_information() noexcept {
    if (!active || !ped.is_available())
        return;

    information.ping = *samp::player_pool::get_ping(id);
    information.armor = ped.get_armor();
    information.weapon = game::weapon_names[ped.get_current_weapon()];
}

void
plugin::server::spectator::update_joystick(std::uint16_t x, std::uint16_t y) noexcept {
    auto now = std::chrono::steady_clock::now();

    if (now - joystick.time < 100ms)
        return;

    joystick.time = now;
    joystick.old = joystick.current;
    joystick.current.x = (x == 0) ? 0 : ((x > 128) ? x - 0xFFFF : x);
    joystick.current.y = (y == 0) ? 0 : ((y > 128) ? y - 0xFFFF : y);
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
    
    auto new_ped = samp::player_pool::get_ped(new_id);

    if (!new_ped)
        return; // No need to report that because it occurs very often (server-related problems?).

    id = new_id;
    nickname = *new_nickname;
    ped = *new_ped;
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
plugin::server::spectator::on_event(const samp::event_type& type, std::uint8_t id, samp::bit_stream* stream) {
    switch (type) {
        case samp::event_type::incoming_rpc:
            switch (id) {
                case samp::text_draw::event_id:
                    return on_show_text_draw(samp::text_draw(stream));
                case samp::text_draw_string_setter::event_id:
                    return on_text_draw_set_string(samp::text_draw_string_setter(stream));
                case samp::text_draw_hider::event_id:
                    return on_text_draw_hide(samp::text_draw_hider(stream));
                case samp::creator_3d_text::event_id:
                    return on_show_3d_text(samp::creator_3d_text(stream));
                case samp::remover_3d_text::event_id:
                    return on_remove_3d_text(samp::remover_3d_text(stream));
                case samp::dialog::event_id:
                    return on_show_dialog(samp::dialog(stream));
                case samp::menu::event_id:
                    return !(*configuration)["additions"]["hide_spectator_menu"];
                default:
                    return true;
            }
        case samp::event_type::incoming_packet:
            switch (id) {
                case samp::player_synchronization::event_id:
                    return on_player_synchronization(samp::player_synchronization(stream));
                case samp::vehicle_synchronization::event_id:
                    return on_vehicle_synchronization(samp::vehicle_synchronization(stream));
                case samp::passenger_synchronization::event_id:
                    return on_passenger_synchronization(samp::passenger_synchronization(stream));
                case samp::bullet_synchronization::event_id:
                    return on_bullet_synchronization(samp::bullet_synchronization(stream));
                default:
                    return true;
            }
        default:
            return true;
    }
}

void
plugin::server::spectator::main_loop() {
    if (!active)
        return;

    if (auto new_ped = samp::player_pool::get_ped(id)) {
        ped = *new_ped;

        if (samp::vehicle vehicle = ped.get_vehicle(); vehicle.is_available()) {
            information.move_speed_max = game::get_max_vehicle_model_speed(vehicle.get_model_index());
            return;
        }

        information.move_speed_current = ped.get_speed();
        information.move_speed_max = game::get_max_ped_model_speed(ped.get_model_index());
    
        return;
    }

    auto now = std::chrono::steady_clock::now();

    if (samp::utils::is_inputs_active() || now - last_reload < 1s)
        return;

    last_reload = now;
    send_menu_option<menu_option::reload>();
}
