#include "plugin/cheats/airbreak.h"
#include "plugin/game/camera.h"
#include "plugin/game/pad.h"
#include "plugin/game/ped.h"
#include "plugin/gui/notify.h"
#include "plugin/plugin.h"
#include "plugin/samp/utils.h"
#include "plugin/server/user.h"
#include "plugin/server/spectator.h"
#include <cmath>

void
plugin::cheats::airbreak::hotkey_callback(gui::hotkey& hotkey) {
    auto cheat_configuration = (*configuration)["cheats"]["airbreak"];
    
    if (!cheat_configuration["use"] || !server::user::is_on_alogin() || server::spectator::is_active())
        return;

    game::ped player_ped = game::ped::get_player();
    game::vehicle player_vehicle = player_ped.get_vehicle();
    game::placeable common = (player_vehicle)
        ? static_cast<game::placeable>(player_vehicle)
        : player_ped;

    cheat_active ^= true;

    if (cheat_active) {
        coords = player_ped.get_position();
        if (!player_vehicle && player_ped.is_in_the_air())
            coords.z += 3.0f; // Prevents the player from death by falling.
    }

    if (common.is_locked())
        common.set_lock(false);

    game::pad::set_player_enter_vehicle(false);

    std::string notify_title = "AirBreak " + std::string((cheat_active) ? "включен" : "выключен");
    std::string notify_description = std::format("Теперь вы {}можете передвигаться по воздуху. Переключить обратно - {}",
                                                 ((cheat_active) ? "" : "не "), hotkey.bind);

    gui::notify::send(gui::notification(notify_title, notify_description, ICON_INFO));
}

float
plugin::cheats::airbreak::get_heading_from_xy(float x, float y) const {
    float deg = std::atan2(y, x) * (180.0f / std::numbers::pi) - 90.0f;
    return (deg > 0.0f) ? deg : deg + 360.0f;
}

void
plugin::cheats::airbreak::on_alogin_new_state(bool state) {
    if (state || !cheat_active)
        return;

    cheat_active = false;

    game::ped player_ped = game::ped::get_player();
    game::vehicle player_vehicle = player_ped.get_vehicle();
    {
        game::placeable common = (player_vehicle)
            ? static_cast<game::placeable>(player_vehicle)
            : player_ped;
        
        if (common.is_locked())
            common.set_lock(false);
    }
    
    game::pad::set_player_enter_vehicle(false);
}

void
plugin::cheats::airbreak::register_hotkeys(types::not_null<gui::hotkey_handler*> handler) {
    handler->add(hotkey);
}

void
plugin::cheats::airbreak::main_loop() {
    if (!cheat_active)
        return;
    
    game::ped player_ped = game::ped::get_player();
    game::vehicle player_vehicle = player_ped.get_vehicle();
    game::placeable common = (player_vehicle) ? static_cast<game::placeable>(player_vehicle) : player_ped;

    if (!common.is_locked())
        common.set_lock(true);
    
    types::vector_3d camera_active = game::camera::get_active_point_at();
    types::vector_3d camera_coords = game::camera::get_active_coordinates();

    float heading = player_ped.get_heading(); // Heading here is the same as in vehicle: no need to get it from `player_vehicle`.
    float angle = get_heading_from_xy(camera_active.x - camera_coords.x, camera_active.y - camera_coords.y);
    float speed = (*configuration)["cheats"]["airbreak"]["speed"];

    game::pad::set_player_enter_vehicle(true);

    if (player_vehicle) {
        player_vehicle.teleport(coords);
    } else {
        game::pad::disable_player_control();
        player_ped.teleport(coords);
    }

    if (samp::utils::is_inputs_active())
        return;

    if (ImGui::IsKeyDown(ImGuiKey_W)) {
        coords.x += speed * std::sin(-deg_to_rad(angle));
        coords.y += speed * std::cos(-deg_to_rad(angle));

        if (player_vehicle)
            player_vehicle.set_heading(angle);
        else
            player_ped.set_heading(angle);
    } else if (ImGui::IsKeyDown(ImGuiKey_S)) {
        coords.x -= speed * std::sin(-deg_to_rad(heading));
        coords.y -= speed * std::cos(-deg_to_rad(heading));
    }

    if (ImGui::IsKeyDown(ImGuiKey_A)) {
        coords.x -= speed * std::sin(-deg_to_rad(heading - 90));
        coords.y -= speed * std::cos(-deg_to_rad(heading - 90));
    } else if (ImGui::IsKeyDown(ImGuiKey_D)) {
        coords.x -= speed * std::sin(-deg_to_rad(heading + 90));
        coords.y -= speed * std::cos(-deg_to_rad(heading + 90));
    }

    if (ImGui::IsKeyDown(ImGuiKey_Space) || ImGui::IsKeyDown(ImGuiKey_UpArrow))
        coords.z += speed / 2.0f;

    if ((ImGui::IsKeyDown(ImGuiKey_LeftShift) || ImGui::IsKeyDown(ImGuiKey_DownArrow)) && coords.z > -95.0f)
        coords.z -= speed / 2.0f;
}

plugin::cheats::airbreak::airbreak() {
    hotkey = gui::hotkey("Переключить AirBreak", gui::key_bind({ 'Z', 0 }, { .alt = true }, gui::bind_condition::on_alogin))
        .with_callback(std::bind(&airbreak::hotkey_callback, this, std::placeholders::_1));
}
